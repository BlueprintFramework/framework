const path = require('path');
const crypto = require('crypto');
const fs = require('fs');
const webpack = require('webpack');
const AssetsManifestPlugin = require('webpack-assets-manifest');
const ForkTsCheckerWebpackPlugin = require('fork-ts-checker-webpack-plugin');
const TerserPlugin = require('terser-webpack-plugin');
const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;

class BuildCachePlugin {
    constructor(options = {}) {
        this.cacheFile = options.cacheFile || '.build-cache.json';
        this.fileHashes = this.loadCache();
        this.newHashes = {};
    }

    loadCache() {
        try {
            return JSON.parse(fs.readFileSync(this.cacheFile, 'utf8'));
        } catch (e) {
            return {};
        }
    }

    saveCache() {
        fs.writeFileSync(this.cacheFile, JSON.stringify(this.newHashes, null, 2));
    }

    calculateHash(filePath) {
        try {
            const content = fs.readFileSync(filePath);
            return crypto.createHash('md5').update(content).digest('hex');
        } catch (e) {
            return null;
        }
    }

    apply(compiler) {
        compiler.hooks.thisCompilation.tap('BuildCachePlugin', (compilation) => {
            compilation.hooks.buildModule.tap('BuildCachePlugin', (module) => {
                if (module.resource) {
                    const hash = this.calculateHash(module.resource);
                    if (hash) {
                        this.newHashes[module.resource] = hash;
                    }
                }
            });
        });

        compiler.hooks.afterEmit.tap('BuildCachePlugin', () => {
            this.saveCache();
        });
    }
}

const isProduction = process.env.NODE_ENV === 'production';

module.exports = {
    cache: true,
    target: 'web',
    mode: process.env.NODE_ENV,
    devtool: isProduction ? false : (process.env.DEVTOOL || 'eval-source-map'),
    performance: {
        hints: false,
    },
    entry: ['react-hot-loader/patch', './resources/scripts/index.tsx'],
    output: {
        path: path.join(__dirname, '/public/assets'),
        filename: isProduction ? 'bundle.[chunkhash:8].js' : 'bundle.[hash:8].js',
        chunkFilename: isProduction ? '[name].[chunkhash:8].js' : '[name].[hash:8].js',
        publicPath: (process.env.WEBPACK_PUBLIC_PATH || '/assets/'),
        crossOriginLoading: 'anonymous',
    },
    module: {
        rules: [
            {
                test: /\.tsx?$/,
                exclude: /node_modules|\.spec\.tsx?$/,
                loader: 'babel-loader',
                options: {
                    cacheDirectory: true,
                }
            },
            {
                test: /\.mjs$/,
                include: /node_modules/,
                type: 'javascript/auto',
            },
            {
                test: /\.css$/,
                use: [
                    { loader: 'style-loader' },
                    {
                        loader: 'css-loader',
                        options: {
                            modules: {
                                auto: true,
                                localIdentName: isProduction ? '[name]_[hash:base64:8]' : '[path][name]__[local]',
                                localIdentContext: path.join(__dirname, 'resources/scripts/components'),
                            },
                            sourceMap: !isProduction,
                            importLoaders: 1,
                        },
                    },
                    {
                        loader: 'postcss-loader',
                        options: { sourceMap: !isProduction },
                    },
                ],
            },
            {
                test: /\.(png|jp(e?)g|gif)$/,
                loader: 'file-loader',
                options: {
                    name: 'images/[name].[hash:8].[ext]',
                },
            },
            {
                test: /\.svg$/,
                loader: 'svg-url-loader',
            },
            {
                test: /\.js$/,
                enforce: 'pre',
                loader: 'source-map-loader',
            }
        ],
    },
    stats: {
        warningsFilter: [/Failed to parse source map/],
    },
    resolve: {
        extensions: ['.ts', '.tsx', '.js', '.json'],
        alias: {
            '@': path.join(__dirname, '/resources/scripts'),
            '@definitions': path.join(__dirname, '/resources/scripts/api/definitions'),
            '@feature': path.join(__dirname, '/resources/scripts/components/server/features'),
        },
    },
    externals: {
        moment: 'moment',
    },
    plugins: [
        new BuildCachePlugin({
            cacheFile: '.build-cache.json'
        }),
        new webpack.EnvironmentPlugin({
            NODE_ENV: 'development',
            DEBUG: process.env.NODE_ENV !== 'production',
            WEBPACK_BUILD_HASH: Date.now().toString(16),
        }),
        new AssetsManifestPlugin({ writeToDisk: true, publicPath: true, integrity: true, integrityHashes: ['sha384'] }),
        new ForkTsCheckerWebpackPlugin({
            typescript: {
                mode: 'write-references',
                diagnosticOptions: {
                    semantic: true,
                    syntactic: true,
                },
            },
            eslint: isProduction ? undefined : {
                files: `${path.join(__dirname, '/resources/scripts')}/**/*.{ts,tsx}`,
            }
        }),
        process.env.ANALYZE_BUNDLE ? new BundleAnalyzerPlugin({
            analyzerHost: '0.0.0.0',
            analyzerPort: 8081,
        }) : null
    ].filter(p => p),
    optimization: {
        usedExports: true,
        sideEffects: false,
        runtimeChunk: false,
        removeEmptyChunks: true,
        minimize: isProduction,
        minimizer: [
            new TerserPlugin({
                cache: isProduction,
                parallel: true,
                extractComments: false,
                terserOptions: {
                    mangle: true,
                    output: {
                        comments: false,
                    },
                },
            }),
        ],
    },
    watchOptions: {
        poll: 1000,
        ignored: /node_modules/,
    },
    devServer: {
        compress: true,
        contentBase: path.join(__dirname, '/public'),
        publicPath: process.env.WEBPACK_PUBLIC_PATH || '/assets/',
        allowedHosts: [
            '.pterodactyl.test',
        ],
        headers: {
            'Access-Control-Allow-Origin': '*',
        },
    },
};
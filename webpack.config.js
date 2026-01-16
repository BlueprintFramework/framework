const path = require('node:path');
const crypto = require('node:crypto');
const fs = require('node:fs');
const webpack = require('webpack');
const { WebpackAssetsManifest } = require('webpack-assets-manifest');
const TerserPlugin = require('terser-webpack-plugin');

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
  mode: isProduction ? 'production' : 'development',
  devtool: process.env.DEVTOOL || (isProduction ? false : 'eval-source-map'),
  performance: {
    hints: false,
  },
  entry: ['react-hot-loader/patch', './resources/scripts/index.tsx'],
  output: {
    path: path.join(__dirname, '/public/assets'),
    filename: isProduction ? 'bundle.[chunkhash:8].js' : 'bundle.[fullhash:8].js',
    chunkFilename: isProduction ? '[name].[chunkhash:8].js' : '[name].[fullhash:8].js',
    publicPath: process.env.WEBPACK_PUBLIC_PATH || '/assets/',
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
        },
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
        test: /\.(woff|woff2)$/i,
        type: 'asset/resource',
      },
      {
        test: /\.svg$/,
        loader: 'svg-url-loader',
      },
      {
        test: /\.js$/,
        enforce: 'pre',
        loader: 'source-map-loader',
      },
    ],
  },
  stats: {
    preset: 'minimal',
    // Ignore warnings emitted by "source-map-loader" when trying to parse source maps from
    // JS plugins we use, namely brace editor.
    warningsFilter: [/Failed to parse source map/],
  },
  resolve: {
    extensions: ['.ts', '.tsx', '.js', '.json'],
    fallback: {
      "path": require.resolve("pathe"),
      "crypto": require.resolve("crypto-browserify")
    },
    alias: {
      '@': path.join(__dirname, '/resources/scripts'),
      '@definitions': path.join(__dirname, '/resources/scripts/api/definitions'),
      '@feature': path.join(__dirname, '/resources/scripts/components/server/features'),
      '@blueprint': path.join(__dirname, '/resources/scripts/blueprint'),
    },
    symlinks: true,
  },
  externals: {
    // Mark moment as an external to exclude it from the Chart.js build since we don't need to use
    // it for anything.
    moment: 'moment',
  },
  plugins: [
    new BuildCachePlugin({
      cacheFile: '.build-cache.json',
    }),
    new webpack.EnvironmentPlugin({
      NODE_ENV: process.env.NODE_ENV || 'development',
      DEBUG: process.env.NODE_ENV !== 'production',
      WEBPACK_BUILD_HASH: Date.now().toString(16),
    }),
    new WebpackAssetsManifest({
      output: 'manifest.json',
      writeToDisk: true,
      publicPath: true,
      integrity: true,
      integrityHashes: ['sha384'],
    }),
  ],
  optimization: {
    usedExports: true,
    sideEffects: false,
    runtimeChunk: false,
    removeEmptyChunks: true,
    minimize: isProduction,
    minimizer: [
      new TerserPlugin({
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
    port: 5173,
    server: {
      type: 'https',
      options: process.env.USE_LOCAL_CERTS
        ? {
            ca: path.join(__dirname, '../../docker/certificates/root_ca.pem'),
            cert: path.join(__dirname, '../../docker/certificates/pterodactyl.test.pem'),
            key: path.join(__dirname, '../../docker/certificates/pterodactyl.test-key.pem'),
          }
        : undefined,
    },
    static: {
      directory: path.join(__dirname, '/public'),
      publicPath: process.env.WEBPACK_PUBLIC_PATH || '/assets/',
    },
    allowedHosts: ['.pterodactyl.test'],
    headers: {
      'Access-Control-Allow-Origin': '*',
    },
  },
};

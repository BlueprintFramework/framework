<?php

namespace Pterodactyl\Http\ViewComposers;

use Illuminate\View\View;
use Pterodactyl\Services\Helpers\AssetHashService;
use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Admin\BlueprintAdminLibrary as BlueprintExtensionLibrary;

class AssetComposer
{
    /**
     * AssetComposer constructor.
     */
    public function __construct(
        private AssetHashService $assetHashService,
        private BlueprintExtensionLibrary $blueprint,
    )
    {}

    /**
     * Provide access to the asset service in the views.
     */
    public function compose(View $view): void
    {
        $blueprintConfiguration = $this->blueprint->dbGetMany('blueprint', [
            'flags:disable_attribution',
        ]);
        $view->with('asset', $this->assetHashService);
        $view->with('siteConfiguration', [
            'name' => config('app.name') ?? 'Pterodactyl',
            'locale' => config('app.locale') ?? 'en',
            'recaptcha' => [
                'enabled' => config('recaptcha.enabled', false),
                'siteKey' => config('recaptcha.website_key') ?? '',
            ],
            'blueprint' => [
                'disable_attribution' => $blueprintConfiguration['flags:disable_attribution'] === '1'
            ]
        ]);
    }
}

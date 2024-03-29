@section("blueprint.lib")
  <?php
    use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Client\BlueprintClientLibrary as BlueprintExtensionLibrary;
    use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;

    $settings = app()->make('Pterodactyl\Contracts\Repository\SettingsRepositoryInterface');
    $blueprint = app()->make(BlueprintExtensionLibrary::class, ['settings' => $settings]);
    $PlaceholderService = app()->make(BlueprintPlaceholderService::class);
  ?>
@endsection

@section("blueprint.wrappers")
  <!--
    Blueprint extensions containing dashboard wrappers
    will have their wrapper code injected here.
  -->

  <!-- wrapper:insert -->
  @foreach (File::allFiles('resources/views/blueprint/dashboard/wrappers') as $partial)
    @if ($partial->getExtension() == 'php')
      @if ($blueprint->dbGet('blueprint', 'extensionconfig_'.str_replace('.blade','',$partial->getPathname()).'_dashboardwrapper') != '0')
        <?php echo(str_replace('.blade','',$partial->getPathname())); ?>
        <?php //@include('blueprint.dashboard.wrappers.'.str_replace('.blade','',$partial->getPathname())) ?>
      @endif
    @endif
  @endforeach
@endsection
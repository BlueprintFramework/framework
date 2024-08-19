@section("blueprint.lib")
  <?php
    use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Admin\BlueprintAdminLibrary as BlueprintExtensionLibrary;
    use Pterodactyl\BlueprintFramework\Services\PlaceholderService\BlueprintPlaceholderService;

    $settings = app()->make('Pterodactyl\Contracts\Repository\SettingsRepositoryInterface');
    $blueprint = app()->make(BlueprintExtensionLibrary::class, ['settings' => $settings]);
    $PlaceholderService = app()->make(BlueprintPlaceholderService::class);
  ?>
@endsection

@section("blueprint.import")
  {!! $blueprint->importStylesheet('https://unpkg.com/boxicons@latest/css/boxicons.min.css') !!}
  {!! $blueprint->importStylesheet('https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css') !!}
  {!! $blueprint->importStylesheet('/assets/extensions/blueprint/admin.extensions.css') !!}
  {!! $blueprint->importStylesheet('/assets/extensions/blueprint/blueprint.style.css') !!}
@endsection

@section("blueprint.navigation")
  <?php
    $extensionsIcon="fa fa-puzzle-piece";
    if($blueprint->fileRead($PlaceholderService->folder()."/.blueprint/extensions/blueprint/private/db/onboarding") == "true"){
      $extensionsIcon="fa fa-puzzle-piece bx-flashing";
    }
  ?>

  <li>
    <li>
      <a href="{{ route('admin.extensions') }}" data-toggle="tooltip" data-placement="bottom" title="Extensions">
        <i class='{{ $extensionsIcon }}'></i>
      </a>
    </li>
  </li>
@endsection

@section("blueprint.notifications")
  <?php
    if($blueprint->fileRead($PlaceholderService->folder()."/.blueprint/extensions/blueprint/private/db/onboarding") == "true") {
      $blueprint->fileWipe($PlaceholderService->folder()."/.blueprint/extensions/blueprint/private/db/onboarding");
    }
    $notification = $blueprint->dbGet("blueprint", "notification:text");
    if($notification != null) {
      echo "<div class=\"notification\">
      <p>".$notification."</p>
      </div>
      ";

      $blueprint->dbSet("blueprint", "notification:text", "");
    }
  ?>
@endsection

@section("blueprint.wrappers")
  @foreach (File::allFiles($PlaceholderService->folder().'/resources/views/blueprint/admin/wrappers') as $partial)
    @if ($partial->getExtension() == 'php')
      @if ($blueprint->dbGet('blueprint', 'extensionconfig_'.str_replace('.blade.php','',basename($partial->getPathname())).'_adminwrapper') != '0')
        @include('blueprint.admin.wrappers.'.str_replace('.blade.php','',basename($partial->getPathname())))
      @endif
    @endif
  @endforeach
@endsection
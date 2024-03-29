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
  <link rel="stylesheet" href="https://unpkg.com/boxicons@latest/css/boxicons.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
  <link rel="stylesheet" href="/assets/extensions/blueprint/admin.extensions.css">
  <link rel="stylesheet" href="/assets/extensions/blueprint/blueprint.style.css">
@endsection

@section("blueprint.cache")
  <!-- Begin Blueprint cache-refresh requirement -->
  <div 
    id="I0TWHOPKAB-1"
    class="I0TWHOPKAB-1"
    style="
      position: fixed;
      bottom: 0px;
      left: 0px;
      background: rgb(23,23,23);
      background: linear-gradient(180deg, rgba(23,23,23,1) 0%, rgba(8,8,8,1) 100%);
      color: white;
      padding: 0px 10px;
      width: 100vw;
      z-index: 6000001;
      height: auto;"
    >
    <p style="font-size: 20px;">
      <code style="background: none; border: none; color: white !important;">[<i style="margin-left:20px">.</i> <i style="margin-right:3px">.</i>]</code>
      <code style="background: none; border: none;">Outdated stylesheets detected.</code>
    </p>
  </div>
  <!-- End Blueprint cache-refresh requirement -->
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
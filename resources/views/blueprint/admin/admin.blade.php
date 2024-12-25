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
  <li>
    <li>
      <a href="{{ route('admin.extensions') }}" data-toggle="tooltip" data-placement="bottom" title="Extensions">
        <i class='fa fa-puzzle-piece'></i>
      </a>
    </li>
  </li>
@endsection

@section("blueprint.sidenav")
  @if($blueprint->dbGet("blueprint", "flags:show_in_sidebar"))
    <li class="{{ ! starts_with(Route::currentRouteName(), 'admin.extensions') ?: 'active' }}">
      <a href="{{ route('admin.extensions') }}">
        <i class="fa fa-puzzle-piece"></i> <span>Extensions</span>
      </a>
    </li>
  @endif
@endsection

@section("blueprint.notifications")
  <?php
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
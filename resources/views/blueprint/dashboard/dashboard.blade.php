@section("blueprint.wrappers")
  <!--
    Blueprint extensions containing dashboard wrappers
    will have their wrapper code injected here.
  -->

  <!-- wrapper:insert -->
  @foreach (File::allFiles(__DIR__ . '/wrappers') as $partial)
    @if ($partial->getExtension() == 'php')
      @if ($blueprint->dbGet('blueprint', 'extensionconfig_'.str_replace('.blade','',$partial->getPathname()).'_dashboardwrapper') != '0')
        @include('blueprint.dashboard.wrappers.'.str_replace('.blade','',$partial->getPathname()))
      @endif
    @endif
  @endforeach
@endsection
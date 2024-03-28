@section("blueprint.wrappers")
  <!--
    Blueprint extensions containing dashboard wrappers
    will have their wrapper code injected here.
  -->

  <!-- wrapper:insert -->
  @foreach (File::allFiles(__DIR__ . '/wrappers') as $partial)
    @if ($partial->getExtension() == 'php')
      @include('blueprint.dashboard.wrappers.'.$partial->getPathname())
    @endif
  @endforeach
@endsection
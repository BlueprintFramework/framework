@extends('templates/wrapper', [
  'css' => ['body' => 'bg-neutral-800'],
])

@section('container')
  <div id="modal-portal"></div>
  @yield('blueprint')
  <div id="app"></div>
@endsection
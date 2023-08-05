@extends('layouts.admin')

@section('title')
  Extensions
@endsection

@section('content-header')
  <h1>Extensions<small>Manage all your installed extensions.</small></h1>
  <ol class="breadcrumb">
    <li><a href="{{ route('admin.index') }}">Admin</a></li>
    <li class="active">Extensions</li>
  </ol>
@endsection

@section('content')
  @if(($bp->isInstalled() != "NOTINSTALLED") && ($bp->version() != "&bp.version"."&"))

    <div class="col-xs-6 col-sm-3 text-center">
      <a href="{{ route('admin.extensions.blueprint.index') }}"><button class="btn btn-gray" style="width:100%;margin-bottom:17px;"><img src="/assets/extensions/blueprint/logo.jpg" alt="logo" class="img-btn"> Blueprint <small>{{ $bp->version() }}</small></button></a>
    </div>
    <!--␀replace␀-->

  @else 
    
    <p><i class='bx bxs-error-alt'></i> You need to finish installing Blueprint to start using extensions.</p>

  @endif
@endsection

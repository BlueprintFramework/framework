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
    <div class="col-xs-6 col-sm-3 text-center">
        <a href="{{ route('admin.extensions.blueprint.index') }}"><button class="btn btn-gray btn-row" style="width:100%;"><img src="/assets/extensions/blueprint/logo.jpg" alt="logo" class="img-btn"> Blueprint <small>{{ $bp->version() }}</small></button></a>
    </div>
    <!-- blueprint.replace -->
@endsection
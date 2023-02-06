@extends('layouts.admin')

@section('title')
    Administration
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
        <a href="{{ route('admin.extensions.blueprint.index') }}"><button class="btn btn-primary" style="width:100%;margin-bottom:25px;"><img src="/assets/extensions/blueprint/logo.jpg" alt="logo" style="width:25px;height:25px;border-radius:3px;margin-right:2px;"> Blueprint <small>indev</small></button></a>
    </div>
    <!-- blueprint.replace -->
@endsection
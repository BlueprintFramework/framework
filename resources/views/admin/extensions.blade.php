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
        <a href=""><button class="btn btn-primary" style="width:100%;margin-top:25px;"><i class="fa fa-fw fa-wrench"></i> Blueprint <small>indev</small></button></a>
    </div>
    <!-- blueprint.replace -->
@endsection
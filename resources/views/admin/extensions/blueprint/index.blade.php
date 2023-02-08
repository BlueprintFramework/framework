@extends('layouts.admin')

@section('title')
    Administration
@endsection

@section('content-header')
    <img src="/assets/extensions/blueprint/logo.jpg" alt="logo" style="float:left;width:30px;height:30px;border-radius:3px;margin-right:5px;">
    <h1 ext-title>Blueprint<tag mg-left blue>indev</tag></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.extensions') }}">Extensions</a></li>
        <li class="active">Blueprint</li>
    </ol>
@endsection

@section('content')
    <div class="row">
        <div class="col-xs-6 col-sm-3 text-center">
            <a href=""><button class="btn btn-transparent" style="width:100%;"><i class='bx bx-trash-alt'></i> placeholder </button></a>
        </div>
        <div class="col-xs-6 col-sm-3 text-center">
            <a href="https://pterodactyl.io"><button class="btn btn-clear" style="width:100%;"><i class="fa fa-fw fa-link"></i> placeholder </button></a>
        </div>
        <div class="col-xs-6 col-sm-3 text-center">
            <a href="https://github.com/pterodactyl/panel"><button class="btn btn-clear" style="width:100%;"><i class="fa fa-fw fa-support"></i> placeholder </button></a>
        </div>
        <div class="col-xs-6 col-sm-3 text-center">
            <a href=""><button class="btn btn-clear" style="width:100%;"><i class="fa fa-fw fa-money"></i> placeholder </button></a>
        </div>
    </div>
    <p>placeholder</p>
@endsection
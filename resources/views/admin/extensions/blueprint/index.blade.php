@extends('layouts.admin')

@section('title')
    Blueprint
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
    <p>Blueprint is the framework that drives all Blueprint-compatible extensions and allows multiple extensions to be installed at the same time.</p>
    <div class="row">
        <div class="col-xs-3">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title"><i class='bx bxs-pen' style='margin-right:5px;'></i>License</h3>
                </div>
                <div class="box-body">
                    @if ($bp->licenseIsValid())
                        Your attached license key is valid. You can manage your license key below.
                    @else
                        You have not attached a (valid) license key. Blueprint is limited until you attach a valid license key.
                    @endif
                </div>
                <div class="box-footer">
                    @if ($bp->licenseIsValid())
                        <a href="{{ $root }}/license"><button class="btn btn-gray-alt btn-sm pull-right">Manage</button></a>
                    @else
                        <a href="{{ $root }}/license"><button class="btn btn-gray-alt btn-sm pull-right">Resolve</button></a>
                    @endif
                </div>
            </div>
        </div>
    </div>
@endsection
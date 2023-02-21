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
                        <input type="text" id="license" value="{{ $bp->licenseKeyCensored() }}" class="form-control" style="letter-spacing: 3px;" readonly/>
                        <p class="text-muted small">Blueprint automatically detects and validates your license key. If any problems occur, we'll let you know here.</p>
                    @endif
                    @if ($bp->licenseIsBlacklisted())
                        <input type="text" id="license" value="{{ $bp->licenseIsBlacklisted() }}" class="form-control" style="letter-spacing: 3px;" readonly/>
                        <p class="text-muted small">Your license key is not valid. This may happen when you share your installation with others, receive a refund for your purchase or break our Terms of Service.</p>
                    @endif
                    @if (!$bp->licenseIsValid())
                        <input type="text" id="license" value="{{ $bp->licenseKeyCensored() }}" class="form-control" style="letter-spacing: 3px;" readonly/>
                        <p class="text-muted small">Your license key could not be validated. This may happen when your panel loses connection to the internet or if our license server is down. You do not have to do anything, this will be solved automatically.</p>
                    @endif
                </div>
            </div>
        </div>
        <div class="col-xs-9">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title"><i class='bx bxs-cog' style='margin-right:5px;'></i>Configuration</h3>
                </div>
                <div class="box-body">
                    <div class="row">
                        <div class="col-xs-4">
                            <label class="control-label">placeholder</label>
                            <input type="text" id="placeholder" value="placeholder" class="form-control" @if(!$bp->licenseIsValid())readonly @endif/>
                            <p class="text-muted small">placeholder</p>
                        </div>
                        <div class="col-xs-4">
                            <label class="control-label">placeholder</label>
                            <input type="text" id="placeholder" value="placeholder" class="form-control" @if(!$bp->licenseIsValid())readonly @endif/>
                            <p class="text-muted small">placeholder</p>
                        </div>
                        <div class="col-xs-4">
                            <label class="control-label">placeholder</label>
                            <input type="text" id="placeholder" value="placeholder" class="form-control" @if(!$bp->licenseIsValid())readonly @endif/>
                            <p class="text-muted small">placeholder</p>
                        </div>
                    </div>
                </div>
                <div class="box-footer">
                    @if ($bp->licenseIsValid())
                        <a href=""><button class="btn btn-gray-alt btn-sm pull-right">Save</button></a>
                    @else
                        <p class="text-muted small">You are required to have a valid license key attached to be able to change any settings.</p> 
                    @endif
                </div>
            </div>
        </div>
    </div>
@endsection
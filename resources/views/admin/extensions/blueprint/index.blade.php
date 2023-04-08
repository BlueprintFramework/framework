@extends('layouts.admin')

@section('title')
    Blueprint
@endsection

@section('content-header')
    <img src="/assets/extensions/blueprint/logo.jpg" alt="logo" style="float:left;width:30px;height:30px;border-radius:3px;margin-right:5px;">
    <h1 ext-title>Blueprint<tag mg-left blue>{{ $bp->version() }}</tag></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.extensions') }}">Extensions</a></li>
        <li class="active">Blueprint</li>
    </ol>
@endsection

@section('content')
    {{ $bp->rlKey() }}
    <p>Blueprint is the framework that powers all Blueprint-compatible extensions, enabling multiple extensions to be installed and used simultaneously.</p>
    <div class="row">
        <div class="col-xs-3">
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title"><i class='bx bxs-shapes' style='margin-right:5px;'></i></i>Overview</h3>
                </div>
                <div class="box-body">
                    <p>You are currently using version <code>{{ $bp->version() }}</code>.</p>
                </div>
            </div>
            <div class="box">
                <div class="box-header with-border">
                    <h3 class="box-title"><i class='bx bxs-pen' style='margin-right:5px;'></i>License</h3>
                </div>
                <div class="box-body">
                    @if ($b)
                        <input type="text" id="license" value="{{ $bp->licenseKeyCensored() }}" class="form-control" style="letter-spacing: 3px;" readonly/>
                        <p class="text-muted small">Your license key is valid. <a data-toggle="modal" data-target="#licenseMoreInfo">Learn more</a></p>
                    @else
                        <input type="text" id="license" value="{{ $bp->licenseKeyCensored() }}" class="form-control" style="letter-spacing: 3px;" readonly/>
                        <p class="text-muted small">Your license key could not be validated. <a data-toggle="modal" data-target="#licenseMoreInfo">Learn more</a></p>
                    @endif
                </div>
            </div>  
        </div>
        <div class="col-xs-9">
            <form action="" method="POST">
                <div class="box">
                    <div class="box-header with-border">
                        <h3 class="box-title"><i class='bx bxs-cog' style='margin-right:5px;'></i>Configuration</h3>
                    </div>
                    <div class="box-body">
                        <div class="row">
                            <div class="col-xs-4">
                                <label class="control-label">placeholder</label>
                                <input type="text" required name="placeholder" id="placeholder" value="{{ $bp->dbGet('placeholder') }}" class="form-control" @if(!$bp->b())readonly @endif/>
                                <p class="text-muted small">placeholder</p>
                            </div>
                            <div class="col-xs-4">
                                <label class="control-label">placeholder</label>
                                <input type="text" required name="placeholder" id="placeholder" value="{{ $bp->dbGet('placeholder') }}" class="form-control" @if(!$bp->a())readonly @endif/>
                                <p class="text-muted small">placeholder</p>
                            </div>
                            <div class="col-xs-4">
                                <label class="control-label">Developer Mode</label>
                                <select class="form-control" name="developer">
                                    <option value="false">Disabled</option>
                                    <option value="true" @if($bp->dbGet('developer')) @endif>Enabled</option>
                                </select>
                                <p class="text-muted small">Enable or disable developer-oriented features.</p>
                            </div>
                        </div>
                    </div>
                    <div class="box-footer">
                        @if ($a)
                            {{ csrf_field() }}
                            <button type="submit" name="_method" value="PATCH" class="btn btn-gray-alt btn-sm pull-right">Save</button>
                        @else
                            <p class="text-muted small">You are required to have a valid license key attached in order to change any settings.</p> 
                        @endif
                    </div>
                </div>
            </form>
        </div>
    </div>
    <div class="modal fade" id="licenseMoreInfo" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <i class='bx bxs-pen' style='margin-right:6px;float:left;font-size:23px;'></i><h4 class="modal-title" style="font-size:19px;">License</h4>
                </div>
                <div class="modal-body">
                    <p>
                        Every purchase comes with a unique license key pre-installed into your Blueprint files, which allows our license system to function without requiring any user input. 
                        Most of the time, this system does not affect the user experience. However, in rare cases, our validation server may be offline and unable to validate licenses. 
                        If this occurs, it should automatically resolve itself within 24 hours.
                        <br><br>
                        Some data, such as IP addresses and licenses, may be shared with the Blueprint team to enable our license system to function properly. This also allows us to revoke licenses remotely in case of abuse or piracy.
                    </p>
                </div>
                <div class="modal-footer">
                    <button class="btn btn-gray-alt btn-sm pull-right" data-dismiss="modal" aria-label="Close">Close</button>
                </div>
            </div>
        </div>
    </div>
@endsection
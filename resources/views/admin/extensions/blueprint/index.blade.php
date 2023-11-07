@extends('layouts.admin')

@section('title')
  Blueprint
@endsection

@section('content-header')
  <img src="/assets/extensions/blueprint/logo.jpg" alt="logo" style="float:left;width:30px;height:30px;border-radius:3px;margin-right:5px;">
  <a href="https://ptero.shop" target="_blank"><button class="btn btn-gray-alt pull-right" style="padding: 5px 10px;"><i class="bx bx-link-external"></i></button></a>
  <a href="https://github.com/teamblueprint/main" target="_blank"><button class="btn btn-gray-alt pull-right" style="padding: 5px 10px; margin-right: 7px;"><i class="bx bx-git-branch"></i></button></a>
  <h1 ext-title>Blueprint<tag mg-left @if($versionLatest != $bp->version()) red @else blue @endif>{{ $bp->version() }}</tag></h1>
@endsection

@section('content')
  {{ $bp->serve() }}
  {{ $telemetry->send("SERVE_BLUEPRINT_ADMIN") }}
  <p>Blueprint is the framework that powers all Blueprint-compatible extensions, enabling multiple extensions to be installed and used simultaneously.</p>
  <div class="row">
    <div class="col-lg-3 col-md-3 col-sm-12 col-xs-12">

      <!-- Overview -->
      <div class="box @if($versionLatest != $bp->version()) box-danger @else box-info @endif">
        <div class="box-header with-border">
          <h3 class="box-title"><i class='bx bxs-shapes' style='margin-right:5px;'></i></i>Overview</h3>
        </div>
        <div class="box-body">
          <p>You are currently using version <code>{{ $bp->version() }}</code>@if($versionLatest != $bp->version()) which is outdated. @else. @endif</p>
        </div>
      </div>

    </div>
    <div class="col-lg-9 col-md-9 col-sm-12 col-xs-12">
      <form action="" method="POST">
        <div class="box">
          <div class="box-header with-border">
          <h3 class="box-title"><i class='bx bxs-cog' style='margin-right:5px;'></i>Configuration</h3>
        </div>
        <div class="box-body">
          <div class="row">
            <div class="col-lg-4 col-md-4 col-sm-4 col-xs-12">
              <label class="control-label">Telemetry</label>
              <select class="form-control" name="telemetry">
                <option value="true">Enabled</option>
                <option value="false" @if($bp->dbGet('telemetry') != "true") selected @endif>Disabled</option>
              </select>
              <p class="text-muted small">Automatically share anonymous usage data with Blueprint.</p>
            </div>
            <div class="col-lg-4 col-md-4 col-sm-4 col-xs-12">
              <label class="control-label">ID</label>
              <input type="text" required name="panel:id" id="panel:id" value="{{ $bp->dbGet('panel:id') }}" class="form-control" readonly/>
              <p class="text-muted small">Randomly generated string with your version that is used as a panel identifier.</p>
            </div>
            <div class="col-lg-4 col-md-4 col-sm-4 col-xs-12">
              <label class="control-label">Developer Mode</label>
              <select class="form-control" name="developer">
                <option value="true">Enabled</option>
                <option value="false" @if($bp->dbGet('developer') != "true") selected @endif>Disabled</option>
              </select>
              <p class="text-muted small">Enable or disable developer-oriented features.</p>
            </div>
          </div>
        </div>
        <div class="box-footer">
          {{ csrf_field() }}
          <button type="submit" name="_method" value="PATCH" class="btn btn-gray-alt btn-sm pull-right">Save</button>
        </div>
      </form>
    </div>
  </div>
@endsection

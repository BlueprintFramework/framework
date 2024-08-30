@extends('layouts.admin')

@section('title')
  Blueprint
@endsection

@section('content-header')

  <!-- Page logo -->
  <img src="/assets/extensions/blueprint/logo.jpg" alt="logo" style="float:left;width:30px;height:30px;border-radius:3px;margin-right:5px;">
  
  <!-- Website button -->
  <a href="https://blueprint.zip" target="_blank"><button class="btn btn-gray-alt pull-right" style="padding: 5px 10px;"><i class="bx bx-link-external"></i></button></a>
  
  <!-- GitHub button -->
  <a href="https://github.com/BlueprintFramework/framework" class="pull-right" target="_blank">
    <button class="btn btn-gray-alt" style="padding: 5px 10px; margin-right: 7px;"><i class="bx bx-git-branch"></i></button>
    @if($ExtensionLibrary->dbGet("blueprint", "git-hint") != "0")
      <div class="blueprint:push-repo">
        <div class="blueprint:push-container">
          <p>Contribute to the Blueprint framework through GitHub.</p>
        </div>
      </div>
      <?php $ExtensionLibrary->dbSet("blueprint", "git-hint", "0"); ?>
    @endif
  </a>

  <!-- Page title -->
  <h1 ext-title>Blueprint<tag mg-left @if($LatestVersion != $PlaceholderService->version()) red @else blue @endif>{{ $PlaceholderService->version() }}</tag></h1>

@endsection

@section('content')
  <p class="ext-description">Blueprint is the framework that powers all Blueprint-compatible extensions, enabling multiple extensions to be installed and used simultaneously.</p>
  <div class="row">
    <div class="col-lg-3 col-md-3 col-sm-12 col-xs-12">

      <!-- Overview -->
      <div class="box @if($LatestVersion != $PlaceholderService->version()) box-danger @else box-info @endif">
        <div class="box-header with-border">
          <h3 class="box-title"><i class='bx bxs-shapes'></i> Overview</h3>
        </div>
        <div class="box-body">
          <p>You are currently using version <code>{{ $PlaceholderService->version() }}</code>@if($LatestVersion != $PlaceholderService->version()) which is outdated. @else. @endif</p>
        </div>
      </div>

    </div>
    <div class="col-lg-9 col-md-9 col-sm-12 col-xs-12">
      <form action="" method="POST" autocomplete="off">
        <div class="box">
          <div class="box-header with-border">
          <h3 class="box-title"><i class='bx bxs-cog'></i> Configuration</h3>
        </div>
        <div class="box-body">
          <div class="row">
            <!-- Telemetry -->
            <div class="col-lg-4 col-md-4 col-sm-4 col-xs-12">
              <label class="control-label">Telemetry</label>
              <select class="form-control" name="telemetry">
                <option value="true">Enabled</option>
                <option value="false" @if($ExtensionLibrary->dbGet('blueprint', 'telemetry') != "true") selected @endif>Disabled</option>
              </select>
              <p class="text-muted small">Automatically share anonymous usage data with Blueprint.</p>
            </div>
            <!-- Identifier -->
            <div class="col-lg-4 col-md-4 col-sm-4 col-xs-12">
              <label class="control-label">Identifer</label>
              <input type="text" required name="panel:id" id="panel:id" value="{{ $ExtensionLibrary->dbGet('blueprint', 'panel:id') }}" class="form-control" readonly/>
              <p class="text-muted small">Randomly generated string with your version that is used as a panel identifier.</p>
            </div>
            <!-- Developer Mode -->
            <div class="col-lg-4 col-md-4 col-sm-4 col-xs-12">
              <label class="control-label">Developer Mode</label>
              <select class="form-control" name="developer">
                <option value="true">Enabled</option>
                <option value="false" @if($ExtensionLibrary->dbGet('blueprint', 'developer') != "true") selected @endif>Disabled</option>
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

  <p style="text-align: center"><img src="/assets/extensions/blueprint/byte.png" class="byte-img"></p>


  <style>
    section.content { padding-top: 7px !important; }
    section.content-header > h1 { margin-top: 3px !important; }
    .ext-description { padding-bottom: 10px; }
  </style>
@endsection

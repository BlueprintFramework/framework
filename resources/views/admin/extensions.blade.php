@extends('layouts.admin')

@section('title')
  Extensions
@endsection

@section('content-header')
  <div class="blueprint-page-header">
    <div class="row">
      <div class="col-lg-8 col-md-9 col-sm-9 col-xs-12" style="padding-top: 3px; padding-bottom: 3px;">
        <p>
          <span class="text-bold h4">Blueprint</span>
        </p>
        <span>
          Powerful, fast and developer-friendly extension framework for Pterodactyl. Utilize extension APIs, inject HTML, modify stylesheets, package extensions and so much more. 
        </span>
      </div>
      <div class="col-lg-4 col-md-3 col-sm-3 col-xs-12" style="padding-top: 3px; padding-bottom: 3px;">
        <a href="https://blueprint.zip/" target="_blank" class="pull-right text-bold">
          Learn more
          <i class='bx bx-link-external' ></i>
        </a>
      </div>
    </div>
  </div>

  <style>
    .blueprint-page-header {
      width: 100%;
      background-color: #1f2933;
      border-radius: 8px;
      padding: 14px 20px;
      background-image: linear-gradient(
        to right,
        #1f2933 50%,
        transparent 100%
      ), url('/assets/extensions/blueprint/promo-blur.jpg');
      background-size: 100% 100%, cover;
      background-position: left center, right center;
      background-repeat: no-repeat;
    }
  </style>
@endsection

@section('content')
  @if(($PlaceholderService->installed() != "NOTINSTALLED") && ($PlaceholderService->version() != "::"."v"))
    <div class="row" style="padding-left: 15px; padding-right: 10px;">
      <div class="col-lg-3 col-md-4 col-sm-6 col-xs-12 text-center" style="padding-left: 0px; padding-right: 17px;">
        <button class="btn extension-btn" style="width:100%;margin-bottom:17px;" data-toggle="modal" data-target="#blueprintConfigModal">
          <div class="extension-btn-overlay"></div>
          <img src="/assets/extensions/blueprint/logo.jpg" alt="logo" class="extension-btn-image2"/>
          <img src="/assets/extensions/blueprint/logo.jpg" alt="logo" class="extension-btn-image"/>
          <p class="extension-btn-text">Blueprint</p>
          <p class="extension-btn-version">
            <span style="padding-right:5px">
              <i class="bi bi-gear-fill"></i>
              <b>system</b>
            </span>
            {{ $PlaceholderService->version() }}
          </p>
          <i class="bi bi-three-dots-vertical" style="font-size: 20px;position: absolute;top: 25px;right: 37px;"></i>
        </button>
      </div>

      @foreach($blueprint->extensions() as $extension)
        @include("blueprint.admin.entry", [
          'EXTENSION_ID' => $extension['identifier'],
          'EXTENSION_NAME' => $extension['name'],
          'EXTENSION_VERSION' => $extension['version'],
          'EXTENSION_ICON' => !empty($extension['icon']) 
            ? '/assets/extensions/'.$extension['identifier'].'/icon.'.pathinfo($extension['icon'], PATHINFO_EXTENSION)
            : '/assets/extensions/'.$extension['identifier'].'/icon.jpg'
        ])
      @endforeach

      <div class="col-lg-3 col-md-4 col-sm-6 col-xs-12 text-center" style="padding-left: 0px; padding-right: 20px;">
        <a href="https://blueprint.zip/browse" target="_blank">
          <button class="blueprint-add" style="margin-bottom:17px;">
            <i class="bi bi-plus" style="font-size: 36px"></i>
          </button>
        </a>
      </div>

      <style>
        .blueprint-add {
          background-color:rgb(44, 55, 67);
          border: transparent;
          border-radius: 8px;
          height: 79px;
          width: 79px;
          float: left;
          color: #CAD1D8;
        }
      </style>
    </div>



    <!-- Blueprint configuration -->
    <div class="modal fade" id="blueprintConfigModal" tabindex="-1" role="dialog">
      <div class="modal-dialog" role="document">
        <div class="modal-content" style="background-color:transparent">
          <form action="/admin/extensions/blueprint/config" method="POST" autocomplete="off">
            <div class="modal-header" style="border-color:transparent; border-radius:7px; margin-bottom: 15px">
              <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="color:#fff;box-shadow:none"><span aria-hidden="true"><i class="bi bi-x"></i></span></button>
              <h3 class="modal-title">
                <img src="/assets/extensions/blueprint/logo.jpg" alt="logo" height="34" width="34" class="pull-left" style="border-radius:3px;margin-right:10px"/>
                Configure <b>Blueprint</b>
              </h3>
            </div>

            <div class="modal-body" style="border-color:transparent; border-radius:7px; margin-bottom: 15px; padding-bottom: 5px;">
              <table class="table table-hover">
                <thead>
                  <tr>
                    <th>Flag</th>
                    <th>Value</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>
                      <code>
                        is_developer
                      </code>
                    </td>
                    <td>
                      <select class="form-control" name="flags:is_developer" style="border-radius:6px">
                        <option value="1" selected>true</option>
                        <option value="0">false</option>
                      </select>
                    </td>
                  </tr>
                  <tr>
                    <td>
                      <code>
                        telemetry_enabled
                      </code>
                    </td>
                    <td>
                      <select class="form-control" name="flags:telemetry_enabled" style="border-radius:6px;">
                        <option value="1" selected>true</option>
                        <option value="0">false</option>
                      </select>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>

            <div class="modal-footer" style="border-color:transparent; border-radius:7px">
              {{ csrf_field() }}
              <input type="hidden" name="_method" value="PATCH">
              <div class="row">
                <div class="col-sm-10">
                  <p class="text-muted small text-left">Flags enable certain features that may be experimental, unstable, or in development. Modifying these values can affect Blueprint's functionality, stability, and security.</p>
                </div>
                <div class="col-sm-2">
                  <button type="submit" class="btn btn-primary btn-sm" style="width:100%; margin-top:10px; margin-bottom:10px; border-radius:6px">Save</button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>

  @else 
    <p><i class='bx bxs-error-alt'></i> You need to finish installing Blueprint to start using extensions.</p>
  @endif

  <style>
    /* backwards compatibility - waiting on slate implementation */
    <?php
      if($blueprint->extension("slate")) {
        echo("
          .extension-btn-overlay {
            background: linear-gradient(90deg, rgba(24,24,27,0.35) 0%, rgba(24,24,27,1) 95%);
          }
          .btn.extension-btn:hover {
            background-color: #18181b !important;
            background: #18181b !important;
          }
        ");
      }
    ?>

    /* style content */
    a:has(button.btn.extension-btn) { 
      height: 96px;
      display: inline-block;
      width: 100%;
    }
    section.content {
      padding-right: 0px !important;
      display: inline-block !important;
      width: 100% !important;
    }
  </style>
@endsection
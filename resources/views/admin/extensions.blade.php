@extends('layouts.admin')

@section('title')
  Extensions
@endsection

@section('content-header')
  <div class="blueprint-page-header">
    <div class="row">
      <div class="col-lg-8 col-md-9 col-sm-9 col-xs-12">
        <p>
          <span class="text-bold h4">Blueprint</span>
        </p>
        <span>
          Powerful, fast and developer-friendly extension framework for Pterodactyl. Utilize extension APIs, inject HTML, modify stylesheets, package extensions and so much more. 
        </span>
      </div>
      <div class="col-lg-4 col-md-3 col-sm-3 col-xs-12">
        <a href="https://blueprint.zip/" target="_blank" class="pull-right text-bold">
          Learn more
          <i class='bx bx-link-external' ></i>
        </a>
      </div>
    </div>
  </div>

  <style>
    .blueprint-page-header {
      width: calc(100% - 4px);
      background-color: #1f2933;
      border-radius: 8px;
      padding: 20px 20px;
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

    <div class="col-lg-3 col-md-4 col-sm-6 col-xs-12 text-center" style="padding-left: 0px; padding-right: 20px;">
      <a href="{{ route('admin.extensions.blueprint.index') }}">
        <button class="btn extension-btn" style="width:100%;margin-bottom:17px;">
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
          <i class="bi bi-arrow-right-short" style="font-size: 34px;position: absolute;top: 15px;right: 35px;"></i>
        </button>
      </a>
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
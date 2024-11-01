@extends('layouts.admin')

@section('title')
  Extensions
@endsection

@section('content-header')
  <a href="https://blueprint.zip/browse" target="_blank">
    <button class="btn btn-gray-alt pull-right" style="padding: 5px 10px">
      Find more extensions
    </button>
  </a>

  <h1 style="margin-top:5px">
    Extensions
    <small>
      Manage and configure all of your installed extensions.
    </small>
  </h1>
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

    <!-- [entryplaceholder] -->

  @else 
    
    <p><i class='bx bxs-error-alt'></i> You need to finish installing Blueprint to start using extensions.</p>

  @endif

  <style>
    /* backwards compatibility - waiting on slate implementation */
    <?php
      if($ExtensionLibrary->extension("slate")) {
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

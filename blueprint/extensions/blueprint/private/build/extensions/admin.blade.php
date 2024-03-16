@extends('layouts.admin')
<?php 
    // Define extension information.
    $EXTENSION_ID = "[id]";
    $EXTENSION_NAME = "[name]";
    $EXTENSION_VERSION = "[version]";
    $EXTENSION_DESCRIPTION = "[description]";
    $EXTENSION_ICON = "[icon]";
    $EXTENSION_WEBSITE = "[website]";
    $EXTENSION_WEBICON = "[webicon]";
?>
@include('blueprint.admin.template')

@section('title')
    {{ $EXTENSION_NAME }}
@endsection

@section('content-header')
    @yield('extension.header')
@endsection

@section('content')
    @yield('extension.config')
    @yield('extension.description')
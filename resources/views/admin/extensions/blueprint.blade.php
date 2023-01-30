@extends('layouts.admin')

@section('title')
    Administration
@endsection

@section('content-header')
    <h1>Blueprint<small>indev</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li><a href="{{ route('admin.extensions') }}">Extensions</a></li>
        <li class="active">Blueprint</li>
    </ol>
@endsection

@section('content')
    <p>placeholder</p>
@endsection
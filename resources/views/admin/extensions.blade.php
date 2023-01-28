@extends('layouts.admin')

@section('title')
    Administration
@endsection

@section('content-header')
    <h1>Extensions<small>Manage all your installed extensions.</small></h1>
    <ol class="breadcrumb">
        <li><a href="{{ route('admin.index') }}">Admin</a></li>
        <li class="active">Extensions</li>
    </ol>
@endsection

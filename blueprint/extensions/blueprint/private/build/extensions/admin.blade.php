@extends('layouts.admin')

@section('title')
    [name]
@endsection

@section('content-header')
    <img src="[icon]" alt="logo" style="float:left;width:30px;height:30px;border-radius:3px;margin-right:5px;"/>
    <!--[web] <a href="[website]" target="_blank"><button class="btn btn-gray-alt pull-right" style="padding: 5px 10px;"><i class="bx [webicon]"></i></button></a> [web]--> 
    <h1 ext-title>[name]<tag mg-left blue>[version]</tag></h1>
@endsection

@section('content')
    <p>[description]</p>
    <form action="/admin/extensions/blueprint/config" method="POST" autocomplete="off">
        <input type="hidden" name="_token" value="{{ csrf_token() }}">
        <input type="hidden" name="_identifier" value="[id]">
        <input type="hidden" name="_method" value="PATCH">

        <button type="submit" id="submit"></button>
    </form>

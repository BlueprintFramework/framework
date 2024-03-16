@section("extension.header")
  <img src="{{ $EXTENSION_ICON }}" alt="logo" style="float:left;width:30px;height:30px;border-radius:3px;margin-right:5px;"/>

  <button class="btn btn-gray-alt pull-right" style="padding: 5px 10px; margin-left: 7px" data-toggle="modal" data-target="#extensionConfigModal">
    <i class="bx bx-slider"></i>
  </button>

  @if($EXTENSION_WEBSITE != "[website]") 
    <a href="{{ $EXTENSION_WEBSITE }}" target="_blank">
      <button class="btn btn-gray-alt pull-right" style="padding: 5px 10px">
        <i class="{{ $EXTENSION_WEBICON }}"></i>
      </button>
    </a>
  @endif

  <h1 ext-title>{{ $EXTENSION_NAME }}<tag mg-left blue>{{ $EXTENSION_VERSION }}</tag></h1>
@endsection

@section("extension.description")
  <p>{{ $EXTENSION_DESCRIPTION }}</p>
@endsection

@section("extension.config")
  <div class="modal fade" id="extensionConfigModal" tabindex="-1" role="dialog">
    <form action="/admin/extensions/blueprint/config" method="POST" autocomplete="off">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <p>hello</p>
          </div>
          <div class="modal-body">
            <p>hello</p>
          </div>
          <div class="modal-footer">
            <p class="text-danger small text-left">hope you like living on the edge because this isn't production-ready yet</p>
            {!! csrf_field() !!}
            <input type="hidden" name="_identifier" value="{{ $EXTENSION_ID }}">
            <input type="hidden" name="_method" value="PATCH">
            <button type="button" class="btn btn-default btn-sm pull-left" data-dismiss="modal">Cancel</button>
            <button type="submit" class="btn btn-success btn-sm">Create</button>
          </div>
        </div>
      </div>
    </form>
  </div>
@endsection
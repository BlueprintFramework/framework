@if(isset($EXTENSION_ID))
  <div class="col-lg-3 col-md-4 col-sm-6 col-xs-12 text-center">
    <a href="{{ route('admin.extensions.'.$EXTENSION_ID.'.index') }}">
      <button class="btn extension-btn" style="width:100%;margin-bottom:17px;">
        <img src="{{ $EXTENSION_ICON }}" alt="logo" class="extension-btn-image"><p class="extension-btn-text">{{ $EXTENSION_NAME }}</p>
        <p class="extension-btn-version">{{ $EXTENSION_VERSION }}</p>
      </button>
    </a>
  </div>
@endif
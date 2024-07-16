@if(isset($EXTENSION_ID))
  <div class="col-lg-3 col-md-4 col-sm-6 col-xs-12 text-center" style="padding-left: 0px; padding-right: 20px;">
    <a href="{{ route('admin.extensions.'.$EXTENSION_ID.'.index') }}">
      <button class="btn extension-btn" style="width:100%;margin-bottom:17px;">
        <div class="extension-btn-overlay"></div>
        <img src="{{ $EXTENSION_ICON }}" alt="{{ $EXTENSION_ID }}" class="extension-btn-image2"/>
        <img src="{{ $EXTENSION_ICON }}" alt="" class="extension-btn-image"/>
        <p class="extension-btn-text">{{ $EXTENSION_NAME }}</p>
        <p class="extension-btn-version">{{ $EXTENSION_VERSION }}</p>
        <i class="bi bi-arrow-right-short" style="font-size: 34px;position: absolute;top: 15px;right: 35px;"></i>
      </button>
    </a>
  </div>
@endif
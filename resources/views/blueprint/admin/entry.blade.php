@if(isset($EXTENSION_ID))
  @php
    $latest = true;
    if(isset($EXTENSION_METADATA)) {
      $diff = str_replace($EXTENSION_METADATA['latest_version'], '', $EXTENSION_VERSION);

      if(
        $EXTENSION_METADATA['latest_version'] != $EXTENSION_VERSION
        && $EXTENSION_METADATA['local_version'] == $EXTENSION_VERSION
        && $diff != "v"
      ) {
        $latest = false;
      }
    }
  @endphp

  <div class="col-lg-3 col-md-4 col-sm-6 col-xs-12 text-center" style="padding-left: 0px; padding-right: 17px;">
    <a href="{{ route('admin.extensions.'.$EXTENSION_ID.'.index') }}">
      <button class="btn extension-btn" style="width:100%;margin-bottom:17px;">
        <div class="extension-btn-overlay"></div>
        <img src="{{ $EXTENSION_ICON }}" alt="{{ $EXTENSION_ID }}" class="extension-btn-image2"/>
        <img src="{{ $EXTENSION_ICON }}" alt="" class="extension-btn-image"/>
        <p class="extension-btn-text">{{ $EXTENSION_NAME }}</p>
        <p class="extension-btn-version" style="opacity: 1 !important;">
          <span style="opacity: .6;">{{ $EXTENSION_VERSION }}</span>
          @if(!$latest)
          <span class="extension-btn-update">
            <i class="bi bi-caret-up-fill"></i>
            <span>{{ $EXTENSION_METADATA['latest_version'] }}</span>
          </span>
          @endif
        </p>
        <i class="bi bi-arrow-right-short" style="font-size: 34px;position: absolute;top: 15px;right: 30px;"></i>
      </button>
    </a>
  </div>
@endif

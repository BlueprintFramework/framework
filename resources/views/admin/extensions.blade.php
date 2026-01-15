@extends('layouts.admin')

@section('title')
  Extensions
@endsection

@php
$is_installed=(($PlaceholderService->installed() != "NOTINSTALLED") && ($PlaceholderService->version() != "::"."v"));
@endphp

@section('content-header')
  @if($is_installed)
    @if(($PlaceholderService->version() != $latestBlueprintVersion) && ($PlaceholderService->version() != "rolling") && $latestBlueprintVersion != "unknown")
      <div class="blueprint-statusbar blueprint-statusbar-danger">
        <div style="margin-right: 14px;">
          <i class="bi bi-exclamation-triangle-fill" style="font-size: 24px; color: #f52e98"></i>
        </div>
        <div>
          <span class="text-bold" style="color: #ff6ab9;">
            Blueprint is out-of-date.
          </span>
          You're running Blueprint
          <code style="border: unset; background-color: unset; color: #cad1d8;">
            {{ $PlaceholderService->version() }}
          </code>
          which is outdated. Update to version
          <code style="border: unset; background-color: unset; color: #cad1d8;">
            {{ $latestBlueprintVersion }}
          </code>
          to access the latest features and improvements.
        </div>
      </div>
    @endif

    @if($PlaceholderService->version() == "rolling")
      <div class="blueprint-statusbar blueprint-statusbar-warning">
        <div style="margin-right: 14px;">
          <i class="bi bi-bug-fill" style="font-size: 24px; color: #f5952e"></i>
        </div>
        <div>
          <span class="text-bold" style="color: #f9a040;">
          This instance is running a development-preview of Blueprint.
          </span>
          You may run into bugs, extension incompatibilities and more. If you run into any issues, please <a href="https://github.com/blueprintframework/framework/issues">let us know</a>.
        </div>
      </div>
    @endif

    @if($latestBlueprintVersion == "unknown" && $PlaceholderService->version() != "rolling")
      <div class="blueprint-statusbar blueprint-statusbar-warning">
        <div style="margin-right: 14px;">
          <i class="bi bi-wifi-off" style="font-size: 24px; color: #f5952e"></i>
        </div>
        <div>
          <span class="text-bold" style="color: #f9a040;">
          Could not fetch version info.
          </span>
          Blueprint failed to fetch the latest release name from the API.
        </div>
      </div>
    @endif

    <div class="blueprint-page-header">
      <div class="row">
        <div class="col-lg-8 col-md-9 col-sm-9 col-xs-12" style="padding-top: 3px; padding-bottom: 3px;">
          <p>
            <span class="text-bold h4">Blueprint</span>
          </p>
          <span>
            Pterodactyl's favorite modding community. Develop, collaborate and install extensions with the extension platform that puts you first. Pterodactyl themes, plugin installers, player managers, admin tools and much more. There's a Blueprint extension for that.
          </span>
        </div>
        <div class="col-lg-4 col-md-3 col-sm-3 col-xs-12" style="padding-top: 3px; padding-bottom: 3px;">
          <a href="https://blueprint.zip/" target="_blank" class="pull-right text-bold">
            Learn more
          </a>
        </div>
      </div>
    </div>
  @endif

  <style>
    .blueprint-statusbar {
      width: calc(100% + 3px);
      display: flex;
      flex-direction: row;
      align-items: center;
      background-color: #1f2933;
      border-radius: 8px;
      padding: 10px 20px;
      margin-bottom: 15px;
    }
    .blueprint-statusbar.blueprint-statusbar-danger {
      background-image: linear-gradient(
        to left,
        #1f2933 50%,
        #5c143b 100%
      );
    }
    .blueprint-statusbar.blueprint-statusbar-warning {
      background-image: linear-gradient(
        to left,
        #1f2933 60%,
        #a43e006e 100%
      );
    }

    .blueprint-page-header {
      width: calc(100% + 3px);
      background-color: #1f2933;
      border-radius: 8px;
      padding: 14px 20px;
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
  @if($is_installed)
    <div class="row" style="padding-left: 15px; padding-right: 10px;">
      <div class="col-lg-3 col-md-4 col-sm-6 col-xs-12 text-center" style="padding-left: 0px; padding-right: 17px;">
        <button class="btn extension-btn" style="width:100%;margin-bottom:17px;" data-toggle="modal" data-target="#blueprintConfigModal">
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
          <i class="bi bi-three-dots-vertical" style="font-size: 20px;position: absolute;top: 25px;right: 37px;"></i>
        </button>
      </div>

      @foreach($blueprint->extensionsConfigs() as $extension)
        <?php
          $extension = $extension['info'];
        ?>
        @include("blueprint.admin.entry", [
          'EXTENSION_ID' => $extension['identifier'],
          'EXTENSION_NAME' => $extension['name'],
          'EXTENSION_VERSION' => $extension['version'],
          'EXTENSION_ICON' => !empty($extension['icon'])
            ? '/assets/extensions/'.$extension['identifier'].'/icon.'.pathinfo($extension['icon'], PATHINFO_EXTENSION)
            : '/assets/extensions/'.$extension['identifier'].'/icon.jpg'
        ])
      @endforeach

      <div class="col-lg-3 col-md-4 col-sm-6 col-xs-12 text-center" style="padding-left: 0px; padding-right: 20px;">
        <a href="https://blueprint.zip/browse" target="_blank">
          <button class="blueprint-add" style="margin-bottom:17px;">
            <i class="bi bi-plus" style="font-size: 36px"></i>
          </button>
        </a>
      </div>

      <style>
        .blueprint-add {
          background-color:rgb(44, 55, 67);
          border: transparent;
          border-radius: 8px;
          height: 79px;
          width: 79px;
          float: left;
          color: #CAD1D8;
        }

        .blueprint-flag-warning {
          font-size: 14px;
          vertical-align: middle;
          margin-left: 8px;
        }
      </style>
    </div>



    <!-- Blueprint configuration -->
    <div class="modal fade" id="blueprintConfigModal" tabindex="-1" role="dialog">
      <div class="modal-dialog" role="document">
        <div class="modal-content" style="background-color:transparent">
          <form action="/admin/extensions/blueprint" method="POST" autocomplete="off">
            <div class="modal-header" style="border-color:transparent; border-radius:7px; margin-bottom: 15px">
              <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="color:#fff;box-shadow:none"><span aria-hidden="true"><i class="bi bi-x"></i></span></button>
              <h3 class="modal-title">
                <img src="/assets/extensions/blueprint/logo.jpg" alt="logo" height="34" width="34" class="pull-left" style="border-radius:3px;margin-right:10px"/>
                Configure <b>Blueprint</b>
              </h3>
            </div>

            <div class="modal-body" style="border-color:transparent; border-radius:7px; margin-bottom: 15px; padding-bottom: 5px;">
              <table class="table table-hover">
                <thead>
                  <tr>
                    <th style="width:50%">Flag</th>
                    <th>Value</th>
                  </tr>
                </thead>
                <tbody>
                  @foreach($configuration as $key => $value)
                    @if(strpos($key, 'flags:') === 0)
                      @php
                        $flagKey = str_replace('flags:', '', $key);
                        $schema = $seeder->getSchema();
                        $flagConfig = $schema['flags'][$flagKey] ?? null;
                        $flagType = $flagConfig['type'] ?? 'string';
                        $flagHidden = $flagConfig['hidden'] ?? false;
                      @endphp
                      @if($flagHidden != true)
                        <tr data-flag-row data-flag-name="{{ $key }}" data-flag-type="{{ $flagType }}" data-default-value="{{ $defaults[$key] }}">
                          <td>
                            <code>
                              {{ $flagKey }}
                            </code>
                          </td>
                          <td>
                            @switch($flagType)
                              @case('boolean')
                                <select class="form-control" name="{{ $key }}" style="border-radius:6px">
                                  <option value="1" {{ $value ? 'selected' : '' }}>true</option>
                                  <option value="0" {{ !$value ? 'selected' : '' }}>false</option>
                                </select>
                                @break
                              @case('number')
                                <input type="number" class="form-control" name="{{ $key }}" value="{{ $value }}" step="any" style="border-radius:6px">
                                @break
                              @case('integer')
                                <input type="number" class="form-control" name="{{ $key }}" value="{{ $value }}" step="1" style="border-radius:6px">
                                @break

                              @default
                                <input type="text" class="form-control" name="{{ $key }}" value="{{ $value }}" style="border-radius:6px">
                            @endswitch
                          </td>
                        </tr>
                      @endif
                    @endif
                  @endforeach
                </tbody>
              </table>
            </div>

            <div class="modal-footer" style="border-color:transparent; border-radius:7px">
              {{ csrf_field() }}
              <input type="hidden" name="_method" value="PATCH">
              <div class="row">
                <div class="col-sm-10">
                  <p class="text-muted small text-left">Flags enable certain features that may be experimental, unstable, or in development. Modifying these values can affect Blueprint's functionality, stability, and security.</p>
                </div>
                <div class="col-sm-2">
                  <button type="submit" class="btn btn-primary btn-sm" style="width:100%; margin-top:10px; margin-bottom:10px; border-radius:6px">Save</button>
                </div>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>

  @else
    <center>
      <div style="padding-top: 50px;">
        <span style="font-size: 36px">
          <i class="bi bi-info-circle-fill"></i>
        </span>
        <br style="margin-bottom: 12px;">
        <span style="font-size: 20px" class="text-bold">
          Unfinished installation
        </span>
        <br style="margin-bottom: 12px;">
        <span>
          Blueprint is currently only partially installed.<br>
          Finish the
          <a href="https://blueprint.zip/guides/admin/install">installation guide</a>,
          then return to this page afterwards.
        </span>
        <br style="margin-bottom: 12px;">
        <span>
          You may be able to fix this issue by running <code>blueprint -upgrade</code>.
        </span>
      </div>
    </center>
  @endif

  <style>
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
    .skin-blue .wrapper {
      box-shadow: unset;
    }

    .blueprint-button-link {
      font-size: 14px;
      background: unset;
      border: unset;
      color: #ec55ad;
    }
  </style>
@endsection

@section('footer-scripts')
  @parent
  <script>
    document.addEventListener('DOMContentLoaded', () => {
      const flagRows = document.querySelectorAll('[data-flag-row]');

      const createResetButton = (row, input) => {
        const button = document.createElement('button');
        button.className = 'blueprint-button-link reset-flag';
        button.style.padding = '0';
        button.style.marginLeft = '8px';
        button.innerHTML = '<i class="bi bi-exclamation-triangle-fill"></i>';

        const defaultValue = getDefaultValue(row);

        button.addEventListener('click', (e) => {
          e.preventDefault();
          input.value = defaultValue;
          input.dispatchEvent(new Event('change'));
        });

        return button;
      };

      const getDefaultValue = (row) => {
        const flagType = row.dataset.flagType;
        const defaultValue = row.dataset.defaultValue;

        if (flagType === 'boolean' && (!defaultValue || defaultValue === '')) {
          return '0';
        }

        return defaultValue;
      };

      const compareValues = (input, defaultValue) => {
        const flagType = input.closest('[data-flag-row]').dataset.flagType;
        const currentValue = input.value;

        const effectiveDefault = flagType === 'boolean' && (!defaultValue || defaultValue === '')
          ? '0'
          : defaultValue;

        switch (flagType) {
          case 'boolean':
            return currentValue !== effectiveDefault;
          case 'number':
          case 'integer':
            return Number(currentValue) !== Number(effectiveDefault);
          default:
            return String(currentValue) !== String(effectiveDefault);
        }
      };

      const handleValueChange = (row, input) => {
        const defaultValue = getDefaultValue(row);

        const existingButton = row.querySelector('td .reset-flag');
        if (existingButton) {
          existingButton.remove();
        }

        if (compareValues(input, defaultValue)) {
          const resetButton = createResetButton(row, input);
          row.querySelector('td').appendChild(resetButton);
        }
      };

      flagRows.forEach(row => {
        const input = row.querySelector('select, input');
        if (!input) return; // Skip if no input found

        handleValueChange(row, input);

        input.addEventListener('change', () => {
          handleValueChange(row, input);
        });

        if (input.tagName.toLowerCase() === 'input') {
          input.addEventListener('keyup', () => {
            handleValueChange(row, input);
          });
        }
      });
    });
  </script>
@endsection

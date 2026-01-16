<?php
  use Pterodactyl\BlueprintFramework\Libraries\ExtensionLibrary\Admin\BlueprintAdminLibrary as BlueprintExtensionLibrary;

  $settings = app()->make('Pterodactyl\Contracts\Repository\SettingsRepositoryInterface');
  $blueprint = app()->make(BlueprintExtensionLibrary::class, ['settings' => $settings]);
?>

@section("blueprint.introduction")
  @if(!$blueprint->dbGet("blueprint", "flags:introduction_dismissed"))
    <div class="modal fade" id="blueprintIntroductionModal" tabindex="-1" role="dialog">
      <div class="modal-dialog" role="document">
        <div class="modal-content" style="background: transparent;">
          <form action="/admin/extensions/blueprint" method="POST">
            <div style="overflow: hidden; border-radius: 15px 15px 0 0;">
              <img src="/assets/extensions/blueprint/welcomebanner.jpeg" style="width: 100%"/>
            </div>
            <div class="modal-body">
              <h3 class="modal-title">Welcome to Blueprint</h3>
              <p style="padding-top: 5px;">
                Blueprint is the industry-leading tool to build, manage and maintain extensions for the Pterodactyl panel. You are almost ready to manage extensions, this is the last step.
              </p>
              <div class="row" style="padding-top: 5px;">
                <div class="col-xs-12">
                  <div style="background-color: #4C5A67; padding: 10px; border-radius: 8px;">
                    <p style="margin: 0 !important; padding-bottom: 3px;"><strong>Join the Blueprint community</strong></p>
                    <p style="margin: 0 !important;">
                      Become part of the <a href="https://discord.com/servers/blueprint-1063548024825057451" target="_blank">Blueprint Discord community</a> and get notified when new extensions are released, participate with community events and more.
                    </p>
                  </div>
                </div>
              </div>
            </div>
            <div class="modal-footer" style="border-radius: 0 0 15px 15px;">
              <p class="small text-left">By using Blueprint you accept our <a href="https://blueprint.zip/legal/privacy#self-hosted-instance-telemetry" target="_blank">privacy policy</a> under the "Self-Hosted Instance Telemetry" section. You can disable anonymized telemetry data in the Blueprint settings menu.</p>
              <input type="hidden" name="flags:introduction_dismissed" value="1">
              <input type="hidden" name="_method" value="PATCH">
              {!! csrf_field() !!}
              <button type="submit" class="btn btn-primary btn-sm" style="border-radius: 8px;">Take me to my extensions!</button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <script>
      document.addEventListener('DOMContentLoaded', () => {
        $('#blueprintIntroductionModal').modal({
          keyboard: false,
          backdrop: 'static',
          show: true
        })
      })
    </script>
  @endif
@endsection

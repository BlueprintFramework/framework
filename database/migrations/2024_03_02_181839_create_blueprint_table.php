<?php

/* BlueprintFramework database migration */

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Migrations\Migration;

class CreateBlueprintTable extends Migration
{
  /**
   * Run the migrations.
   *
   * @return void
   */
  public function up()
  {
    Schema::create('blueprint', function (Blueprint $table) {
      $table->id();
      $table->timestamp('timestamp')->useCurrent()->onUpdate(null);


      /*
        Placeholder may come useful when developing
        new features, that's why it's currently included
        in the migrations.

        This value will normally contain next to nothing,
        but is always useful to include for experimenting.
      */
      $table->string('placeholder')->nullable();

      /*
        Database value for keeping track of the developer
        mode setting.
      */
      $table->string('developer')->nullable();

      /*
        Database value for keeping track of the telemetry
        opt-out option.
      */
      $table->string('telemetry')->nullable();

      /*
        Randomly generated ID for the panel to use when
        sending telemetry messages.
      */
      $table->string('panel:id')->nullable();

      /*
        Value for keeping track of displaying a GitHub-
        repository-related hint.
      */
      $table->string('git-hint')->nullable();

      /*
        Cache of the previous version name for Blueprint
        know when to reroll the panel ID and to know when
        it has updated.
      */
      $table->string('version:cache')->nullable();

      /*
        String for the notification API in Blueprint. Not
        sure if I'm still using this value, so it might
        get removed in the future.
      */
      $table->string('notification:text')->nullable();
    });
  }

  /**
   * Reverse the migrations.
   *
   * @return void
   */
  public function down()
  {
    Schema::dropIfExists('blueprint');
  }
}
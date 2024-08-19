<?php

/* BlueprintFramework database migration */

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Migrations\Migration;

class AddCacheToBlueprintTable extends Migration
{
  /**
   * Run the migrations.
   *
   * @return void
   */
  public function up()
  {
    Schema::table('blueprint', function (Blueprint $table) {
      
      /*
        Database value for keeping imported stylesheets
        and scripts up-to-date for the end-user by
        bypassing browser cache.
      */
      $table->string('cache')->nullable();

    });
  }

  /**
   * Reverse the migrations.
   *
   * @return void
   */
  public function down()
  {
    Schema::table('blueprint', function (Blueprint $table) {
      $table->dropColumn('cache');
  });
  }
}
<?php

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
        Schema::dropIfExists('blueprint');
        Schema::create('blueprint', function (Blueprint $table) {
            $table->id();

            $table->string('placeholder')->nullable();
            $table->string('developer')->nullable();
            $table->string('telemetry')->nullable();
            $table->string('panel:id')->nullable();
            $table->string('version:cache')->nullable();
            $table->string('notification:text')->nullable();

            $table->timestamp('timestamp')->useCurrent()->onUpdate(null);
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
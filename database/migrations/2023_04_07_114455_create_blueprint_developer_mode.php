<?php

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Migrations\Migration;

class CreateBlueprintDeveloperMode extends Migration
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
            $table->boolean('developer')->nullable();
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
<?php

// Should not be included in database migrations.
// If these files are still here when you downloaded this
// and got included in the database migrations, please let
// us know.

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Database\Migrations\Migration;

class CreateBlueprintTest extends Migration
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
            $table->string('placeholder:1')->nullable();
            $table->string('placeholder:2')->nullable();
            $table->string('placeholder:3')->nullable();
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
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
        Schema::create('blueprint', function (Blueprint $table) {
            $table->id();
            $table->string('placeholder')->nullable(); // Used for work-in-progress options.
            $table->boolean('developer')->nullable();
            $table->timestamp('timestamp')->useCurrent()->onUpdate(null);
        });

        Schema::create('bpkey', function (Blueprint $table) {$table->id();$table->string('k')->nullable();$table->boolean('v')->nullable();$table->timestamp('timestamp')->useCurrent()->onUpdate(null);});
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('blueprint');
        Schema::dropIfExists('bpkey');
    }
}
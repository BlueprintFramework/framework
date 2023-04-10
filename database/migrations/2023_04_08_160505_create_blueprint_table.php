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
            $table->string('placeholder')->nullable(); // Used for work-in-progress options.

            $table->string('developer')->nullable(); // Somehow I can't make it work with a boolean.
            $table->string('developer:cmd')->nullable();
            $table->string('developer:log')->nullable();

            $table->string('api:endpoint')->nullable();

            $table->timestamp('timestamp')->useCurrent()->onUpdate(null);
        });

        Schema::dropIfExists('bpkey');
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
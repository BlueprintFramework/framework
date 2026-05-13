<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('extension_cached_metadata', function (Blueprint $table) {
            $table->id();
            $table->string('identifier')->unique(); // the extensions' identifier
            $table->json('metadata'); // the metadata related to the extension
            $table->timestamp('fetched_at')->nullable(); // last time blueprint fetched ts
            $table->timestamps();

            $table->index(['fetched_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('extension_cached_metadata');
    }
};

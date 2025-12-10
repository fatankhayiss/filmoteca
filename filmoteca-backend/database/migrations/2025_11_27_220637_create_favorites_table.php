<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('favorites', function (Blueprint $table) {
            $table->id();
            $table->string('movie_id'); // ID film dari TMDB
            $table->string('title');
            $table->string('poster_url')->nullable();
            $table->string('release_date')->nullable();
            $table->text('overview')->nullable();
            $table->string('language')->nullable(); // Bahasa film
            $table->timestamps();
        });
    }


    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('favorites');
    }
};

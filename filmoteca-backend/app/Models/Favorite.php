<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Favorite extends Model
{
    protected $fillable = [
        'user_id','movie_id', 'title', 'poster_url', 'release_date', 'overview', 'language'
    ];
}

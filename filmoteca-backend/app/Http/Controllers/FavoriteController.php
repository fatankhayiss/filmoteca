<?php

namespace App\Http\Controllers;

use App\Models\Favorite;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class FavoriteController extends Controller
{
    // Ambil favorit milik user login saja
    public function index(Request $request)
    {
        $user = $request->user();

        return Favorite::where('user_id', $user->id)
            ->orderBy('id', 'desc')
            ->get();
    }

    // Tambah favorit
    public function store(Request $request)
    {
        $user = $request->user();

        // Cek apakah film sudah ada milik user ini
        $existing = Favorite::where('user_id', $user->id)
            ->where('movie_id', $request->movie_id)
            ->first();

        if ($existing) {
            return response()->json(['message' => 'Film sudah ada di favorit'], 409);
        }

        $favorite = Favorite::create([
            'user_id'      => $user->id,
            'movie_id'     => $request->movie_id,
            'title'        => $request->title,
            'poster_url'   => $request->poster_url,
            'overview'     => $request->overview,
            'release_date' => $request->release_date,
            'rating'       => $request->rating,
        ]);

        return response()->json($favorite, 201);
    }

    // Hapus favorit
    public function destroy(Request $request, $id)
    {
        $user = $request->user();

        $favorite = Favorite::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (!$favorite) {
            return response()->json(['message' => 'Data favorit tidak ditemukan'], 404);
        }

        $favorite->delete();

        return response()->json(['message' => 'Berhasil menghapus favorit']);
    }
}

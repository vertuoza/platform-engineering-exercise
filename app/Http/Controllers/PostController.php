<?php

namespace App\Http\Controllers;

use App\Models\Post;
use Illuminate\Http\Request;

class PostController extends Controller
{
    /**
     * Display a listing of published posts
     */
    public function index()
    {
        $posts = Post::published()->paginate(10);
        $postsData = $posts->getCollection()->map(function ($post) {
            return [
                'id' => $post->id,
                'title' => $post->title,
                'content' => substr($post->content, 0, 200) . '...',
                'author_name' => $post->user->name,
                'comment_count' => $post->approvedComments->count(),
                'published_at' => $post->published_at->format('Y-m-d H:i:s'),
            ];
        });

        return response()->json([
            'data' => $postsData,
            'pagination' => [
                'current_page' => $posts->currentPage(),
                'total' => $posts->total(),
                'per_page' => $posts->perPage(),
            ]
        ]);
    }

    /**
     * Display the specified post with comments
     */
    public function show(Post $post)
    {
        $postData = [
            'id' => $post->id,
            'title' => $post->title,
            'content' => $post->content,
            'author' => $post->user,
            'published_at' => $post->published_at,
            'comments' => $post->approvedComments->map(function ($comment) {
                return [
                    'id' => $comment->id,
                    'content' => $comment->content,
                    'author_name' => $comment->user->name,
                    'created_at' => $comment->created_at->format('Y-m-d H:i:s'),
                ];
            }),
        ];

        return response()->json($postData);
    }

    /**
     * Get posts by a specific user
     */
    public function byUser($userId)
    {
        $posts = Post::where('user_id', $userId)
            ->published()
            ->get();

        $postsData = $posts->map(function ($post) {
            return [
                'id' => $post->id,
                'title' => $post->title,
                'comment_count' => $post->approvedComments->count(),
                'published_at' => $post->published_at,
            ];
        });

        return response()->json($postsData);
    }
}

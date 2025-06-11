<?php

namespace Database\Seeders;

use App\Models\Comment;
use App\Models\Post;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class CommentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $posts = Post::where('status', 'published')->get();
        $users = User::all();

        $comments = [
            'Great article! Very helpful information.',
            'Thanks for sharing this. I learned a lot.',
            'This is exactly what I was looking for.',
            'Could you provide more examples?',
            'Excellent explanation of the concepts.',
            'I have a question about the implementation.',
            'This helped me solve my problem.',
            'Looking forward to more posts like this.',
            'Very well written and easy to understand.',
            'Can you cover more advanced topics?',
            'This is a comprehensive guide.',
            'I disagree with some points mentioned here.',
            'Perfect timing! I needed this information.',
            'The examples are very clear.',
            'Would love to see a follow-up post.',
        ];

        foreach ($posts as $post) {
            // Add 3-8 comments per post
            $commentCount = rand(3, 8);

            for ($i = 0; $i < $commentCount; $i++) {
                Comment::create([
                    'content' => $comments[array_rand($comments)],
                    'post_id' => $post->id,
                    'user_id' => $users->random()->id,
                    'is_approved' => rand(0, 10) > 2, // 80% chance of being approved
                ]);
            }
        }
    }
}

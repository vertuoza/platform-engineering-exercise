<?php

namespace Database\Seeders;

use App\Models\Post;
use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class PostSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $users = User::all();

        $posts = [
            [
                'title' => 'Getting Started with Laravel',
                'content' => 'Laravel is a web application framework with expressive, elegant syntax. We believe development must be an enjoyable and creative experience to be truly fulfilling. Laravel takes the pain out of development by easing common tasks used in many web projects.',
                'status' => 'published',
                'published_at' => now()->subDays(5),
            ],
            [
                'title' => 'Docker Best Practices',
                'content' => 'Docker has revolutionized how we deploy applications. In this post, we will explore some best practices for using Docker in production environments, including security considerations and optimization techniques.',
                'status' => 'published',
                'published_at' => now()->subDays(3),
            ],
            [
                'title' => 'Database Optimization Tips',
                'content' => 'Database performance is crucial for any application. This article covers indexing strategies, query optimization, and common pitfalls to avoid when working with databases.',
                'status' => 'published',
                'published_at' => now()->subDays(2),
            ],
            [
                'title' => 'Understanding N+1 Queries',
                'content' => 'N+1 queries are a common performance problem in web applications. Learn how to identify and fix these issues using Laravel\'s eager loading features.',
                'status' => 'published',
                'published_at' => now()->subDays(1),
            ],
            [
                'title' => 'Cloud Deployment Strategies',
                'content' => 'Deploying applications to the cloud requires careful planning. This post discusses various deployment strategies, scaling considerations, and monitoring approaches.',
                'status' => 'published',
                'published_at' => now()->subHours(12),
            ],
            [
                'title' => 'Draft Post About Security',
                'content' => 'This is a draft post about security best practices. It covers authentication, authorization, and common security vulnerabilities.',
                'status' => 'draft',
                'published_at' => null,
            ],
            [
                'title' => 'Performance Monitoring',
                'content' => 'Monitoring application performance is essential for maintaining a good user experience. Learn about various tools and techniques for performance monitoring.',
                'status' => 'published',
                'published_at' => now()->subHours(6),
            ],
            [
                'title' => 'API Design Principles',
                'content' => 'Good API design is crucial for building maintainable applications. This post covers REST principles, versioning strategies, and documentation best practices.',
                'status' => 'published',
                'published_at' => now()->subHours(3),
            ],
        ];

        foreach ($posts as $postData) {
            Post::create([
                'title' => $postData['title'],
                'content' => $postData['content'],
                'user_id' => $users->random()->id,
                'status' => $postData['status'],
                'published_at' => $postData['published_at'],
            ]);
        }
    }
}

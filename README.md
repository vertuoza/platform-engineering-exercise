# Platform Engineering Exercise

## Overview

This is a 30-minute platform engineering exercise designed to test your ability to analyze and optimize a Laravel application for production deployment. You'll need to identify performance bottlenecks, security issues, and optimization opportunities.

## Exercise Structure

### Part 1: Docker & Infrastructure Optimization (10 minutes)
Analyze the containerization setup and identify improvements for production deployment.

### Part 2: Database Performance Analysis (15 minutes)
Review the database schema and application queries to identify performance optimization opportunities.

### Part 3: Cloud Deployment Strategy (5 minutes)
Discuss your approach to deploying this application to the cloud for production use.

---

## Part 1: Docker & Infrastructure Analysis (10 minutes)

### Current Setup
- Review the `Dockerfile` and `docker-compose.yml` files
- Analyze the containerization approach for production readiness

### What to Analyze
- Security considerations
- Image optimization opportunities
- Build efficiency
- Production deployment readiness
- Resource management

### Expected Deliverables
1. **Optimized Dockerfile** with explanations of changes
2. **Improved docker-compose.yml** configuration
3. **Additional configuration files** (e.g., .dockerignore) if needed
4. **Summary of improvements** and their benefits

---

## Part 2: Database Performance Analysis (15 minutes)

### Application Overview
The application is a simple blog platform with:
- **Users** who can create **Posts**
- **Posts** that can have **Comments**
- Posts have different statuses (draft/published) and publication dates
- Comments can be approved or pending approval

### Performance Analysis Tasks
1. **Database Schema Review**: Analyze the database structure for optimization opportunities
2. **Query Performance**: Review the API controllers and identify potential performance bottlenecks
3. **Relationship Efficiency**: Examine how the application loads related data

### API Endpoints for Testing
```bash
# Start the application first
docker-compose up --build

# Run migrations and seed test data
docker-compose exec app php artisan migrate --seed

# Test these endpoints and analyze their performance
curl http://localhost:8000/api/posts
curl http://localhost:8000/api/posts/1
curl http://localhost:8000/api/users/1/posts

# Optional: Enable query logging to analyze database queries
# You can add DB::enableQueryLog() and dd(DB::getQueryLog()) in controllers
```

### Expected Deliverables
1. **Database optimization recommendations** (SQL commands or Laravel migrations)
2. **Controller improvements** for better query performance
3. **Performance impact analysis** explaining the benefits of your changes

---

## Part 3: Cloud Deployment Strategy (5 minutes)

### Scenario
You need to deploy this Laravel application to the cloud for production use with **10,000 daily active users**.

### Discussion Points
Describe your deployment approach covering:

1. **Infrastructure Architecture**
   - Container orchestration platform choice
   - Database hosting strategy
   - Caching implementation

2. **Scaling Strategy**
   - Horizontal vs vertical scaling approach
   - Auto-scaling configuration
   - Load balancing setup

3. **CI/CD Pipeline**
   - Build and deployment process
   - Testing strategy
   - Environment management

4. **Monitoring & Observability**
   - Application performance monitoring
   - Log aggregation and analysis
   - Alerting strategy

5. **Security Considerations**
   - Network security
   - Secrets management
   - Container security best practices

6. **Cost Optimization**
   - Resource optimization strategies
   - Cost monitoring and management

---

## Getting Started

### Prerequisites
- Docker and Docker Compose
- Basic understanding of PHP/Laravel
- Knowledge of SQL and database optimization
- Understanding of containerization best practices

### Setup Instructions

1. **Explore the codebase structure**:
   ```
   ├── Dockerfile              # Container configuration
   ├── docker-compose.yml      # Multi-container setup
   ├── app/
   │   ├── Models/             # User, Post, Comment models
   │   └── Http/Controllers/   # API controllers
   ├── database/
   │   ├── migrations/         # Database schema
   │   └── seeders/           # Test data
   └── routes/web.php          # API routes
   ```

2. **Start the application**:
   ```bash
   docker-compose up --build
   ```

3. **Initialize the database**:
   ```bash
   docker-compose exec app php artisan migrate --seed
   ```

4. **Test the API endpoints** and analyze performance

### Time Management
- **Part 1**: 10 minutes (Docker & infrastructure optimization)
- **Part 2**: 15 minutes (Database performance analysis)
- **Part 3**: 5 minutes (Cloud deployment discussion)

### Success Criteria
- Identify key optimization opportunities in Docker setup
- Recognize database performance bottlenecks and propose solutions
- Demonstrate understanding of production deployment considerations
- Complete analysis within 30 minutes with clear explanations

---

## Evaluation Focus

You will be evaluated on:
- **Analysis Skills**: Ability to identify performance and security issues
- **Solution Quality**: Effectiveness and practicality of proposed improvements
- **Technical Knowledge**: Understanding of platform engineering best practices
- **Communication**: Clear explanation of problems and solutions
- **Prioritization**: Focus on high-impact improvements

## Tips for Success
- Start by understanding the application structure and data flow
- Test the API endpoints to experience any performance issues firsthand
- Consider both development and production environments
- Think about scalability and maintainability
- Explain the reasoning behind your recommendations

Good luck! 🚀

# Salary Management Tool - High Level Architecture

## 1. Overview

This system is a minimal yet production-quality salary management tool designed for an organization with ~10,000 employees. It enables HR managers to manage employee records and derive meaningful salary insights.

The architecture prioritizes:
- Simplicity and clarity
- Performance (especially for seeding and aggregation queries)
- Maintainability and scalability

---

## 2. Tech Stack

### Backend
- Ruby on Rails (API-only mode)
- Service Layer Pattern for business logic
- PostgreSQL (production)
- SQLite (development)

### Frontend
- Next.js (React)
- Component Library: Material UI (MUI)

### Deployment
- Backend + DB: Railway
- Frontend: Vercel

### Testing
- Backend: RSpec / Minitest
- Frontend: React Testing Library

---

## 3. System Architecture

### High-Level Flow

Client (Next.js UI)
        |
        v
Rails API (REST)
        |
        v
Database (PostgreSQL)

---

## 4. Core Modules

### 4.1 Service Layer (Rails)

Purpose:
- Encapsulate complex business logic (used only where necessary)
- Avoid over-engineering simple CRUD flows

Scope Decision:
- Employee CRUD → handled directly in controllers + models
- Insights logic → handled via service layer

Structure:
- app/services/
  - insights/
    - salary_summary_service.rb
    - salary_by_title_service.rb
    - distribution_service.rb
    - outliers_service.rb

Pattern:
- Each service exposes a single `call` method
- Returns structured data (hash or PORO)

---

### 4.2 Employee Management

Responsibilities:
- CRUD operations for employees
- Validation and data integrity

Key Fields:
- full_name
- job_title
- country
- salary
- currency
- department (optional)

---

### 4.3 Insights Engine

Responsibilities:
- Aggregated salary metrics
- Efficient querying using SQL

Metrics:
- Min, Max, Avg salary per country
- Avg salary per job title per country
- Salary distribution (histogram buckets)
- Outlier detection (optional)

---

## 5. API Design

### 5.1 Employee APIs
- POST   /employees
- GET    /employees
- GET    /employees/:id
- PATCH  /employees/:id
- DELETE /employees/:id

Supports:
- Pagination
- Filtering (country, job_title)

---

### 5.2 Insights APIs
- GET /insights/salary?country=
- GET /insights/salary-by-title?country=&job_title=
- GET /insights/distribution?country=
- GET /insights/outliers?country=

---

### 5.3 Error Handling Strategy

Approach:
- Centralized error handling using ApplicationController
- Consistent JSON error responses

Error Response Format:
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input",
    "details": {
      "salary": ["must be greater than 0"]
    }
  }
}

Handled Error Types:
- Validation errors (ActiveRecord::RecordInvalid)
- Record not found (ActiveRecord::RecordNotFound)
- Parameter missing (ActionController::ParameterMissing)
- Custom domain errors

HTTP Status Mapping:
- 400 → Bad Request
- 404 → Not Found
- 422 → Validation errors
- 500 → Internal server error

Implementation:
- Use `rescue_from` in ApplicationController
- Define custom error classes where needed

---

## 6. Database Design

### employees table

Columns:
- id (UUID)
- full_name (string)
- job_title (string)
- country (string)
- salary (integer)
- currency (string)
- department (string)
- created_at
- updated_at

Indexes:
- index on country
- index on job_title
- composite index on (country, job_title)

---

## 7. Data Seeding Strategy

Goal: Efficiently insert 10,000 records

Approach:
- Read from first_names.txt and last_names.txt
- Generate combinations
- Batch insert using insert_all

Performance Considerations:
- Avoid N+1 inserts
- Use bulk operations

---

## 8. Frontend Architecture

### Pages
- Employee Management Page
- Insights Dashboard Page

### Components
- Employee Table
- Filters (country, job title)
- Stats Cards (min/max/avg)
- Charts (distribution)

### Data Fetching
- REST API calls
- Client-side filtering + server-side queries

---

## 9. Performance Considerations

- Use SQL aggregation instead of in-memory computation
- Add indexes for frequent filters
- Use pagination for employee listing
- Optimize seed script using bulk inserts
- Avoid N+1 queries by using `includes` when associations are introduced

---

## 10. Scalability Considerations

Although designed for 10,000 employees, system can scale by:
- Moving to managed PostgreSQL
- Adding caching layer (Redis) for insights
- Background jobs for heavy computations

---

## 11. Testing Strategy

### Backend
- Model validations
- Service layer (insights calculations)
- API endpoints

### Frontend
- Component rendering
- User interactions
- API integration mocks

---

## 12. AI Usage Strategy

- Use AI for scaffolding and boilerplate
- Validate business logic manually
- Store prompts in /docs/ai-prompts.md

---

## 13. Trade-offs

Decision: PostgreSQL over SQLite in production
Reason: Better concurrency, indexing, and aggregation performance

Decision: REST over GraphQL
Reason: Simpler implementation, faster development

Decision: Monolith (Rails)
Reason: Simplicity and faster iteration for assessment

---

## 14. Future Enhancements

- Currency normalization across countries
- Role-based access control
- Export reports (CSV)
- Salary trend analysis over time

---

## 15. Deployment Flow

- Push code to GitHub
- Connect backend to Railway
- Add PostgreSQL service
- Run migrations and seed
- Deploy frontend to Vercel

---

## 16. Conclusion

This architecture balances simplicity, performance, and real-world engineering practices while meeting all assessment requirements. It demonstrates strong backend fundamentals, product thinking, and scalability awareness.


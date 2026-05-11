## Generate The implementation plan

You are a senior Ruby on Rails engineer and system designer.

I have already created a high-level architecture document for a Salary Management Tool. Based on this, I want you to generate a **detailed, step-by-step implementation plan using a Test-Driven Development (TDD) approach**.

### Context

* Backend: Ruby on Rails (API-only)
* Frontend: Next.js with Material UI
* Database: SQLite (development), PostgreSQL (production)
* Scale: ~10,000 employees
* Features:

  * Employee CRUD
  * Salary insights (min, max, avg, salary by job title, distribution, outliers)
  * Service layer only for insights (not for CRUD)
  * Centralized error handling

---

### Inputs

The high-level architecture document is attached.

---

### Expectations from you

Create a **phased implementation plan** that follows strict TDD principles.

#### 1. Break implementation into phases

Example:

* Project setup
* Model & DB design
* Employee APIs
* Insights APIs
* Frontend integration
* Deployment

---

#### 2. For each phase, include:

* What to build
* Tests to write FIRST (before implementation)
* Implementation steps
* Refactoring considerations

---

#### 3. Follow TDD cycle explicitly:

For every feature:

* Write failing test
* Implement minimal code to pass
* Refactor

---

#### 4. Be Rails-specific

* Mention models, controllers, routes
* Use Minitest or RSpec patterns
* Include request specs / model tests
* Show how to test services (for insights)

---

#### 5. Include database considerations

* Migrations
* Indexing strategy
* Constraints
* How to test DB logic

---

#### 6. Include seed script strategy

* TDD approach for seed logic (if applicable)
* Performance considerations

---

#### 7. Include API contract validation

* Test request/response structure
* Error handling tests

---

#### 8. Include frontend TDD (light but structured)

* Component testing strategy
* API mocking

---

#### 9. Include commit strategy

Break work into meaningful incremental commits that reflect TDD workflow.

---

#### 10. Keep it practical

* Avoid overengineering
* Prefer clarity over abstraction
* Focus on production-quality code

---

### Output format

* Structured phases
* Bullet points for each step
* Clear mapping: Test → Code → Refactor
* Use real Rails examples where helpful

---

Do not give generic advice. Be concrete and implementation-ready.

## Generate The README.md file

I want you to generate a professional README.md for my full-stack take-home assessment project.

Project Context:
- Project Name: Salary Management Tool
- Purpose: Internal HR analytics and employee salary management platform
- User Persona: HR Manager
- Scale: Designed for organizations with 10,000 employees

Tech Stack:
Backend:
- Ruby on Rails 8 API-only application
- PostgreSQL (production)
- Sqlite (development)
- RSpec for testing
- FactoryBot
- Faker
- Service objects for analytics/insights logic

Frontend:
- Next.js 16
- TypeScript
- Material UI
- MUI DataGrid
- Recharts
- Axios

Architecture:
- Monorepo structure:
  - /backend
  - /frontend
- Rails backend exposes REST APIs
- Next.js frontend consumes APIs
- Insights/business logic separated into service layer
- CRUD logic handled directly in controllers for simplicity
- Server-side pagination/filtering/sorting

Core Features:
Employee Management:
- Create employee
- Update employee
- Delete employee
- View employees
- Pagination
- Filtering by country and job title
- Sorting

Salary Insights:
- Salary summary
  - minimum salary
  - maximum salary
  - average salary
  - employee count
- Salary distribution chart
- Salary outliers detection
- Country-based insights
- Job title-based insights
- Paginated outliers table

Employee Data:
- full_name
- job_title
- country
- salary
- currency
- department

Performance:
- Seed script generates 10,000 employees
- Uses batch inserts / optimized seeding approach
- Server-side pagination to support scalability

Testing:
- Model specs
- Request specs
- Service specs
- Focus on deterministic and maintainable tests

Error Handling:
- Backend validation errors returned in structured JSON format
- Frontend displays inline form validation errors
- Loading and error states handled gracefully

Deployment:
- Backend deployed on Railway
- Frontend deployed on Vercel

README Requirements:
Generate a polished and production-quality README.md containing:
1. Project overview
2. Features
3. Tech stack
4. Architecture overview
5. Monorepo structure
6. Setup instructions
7. Backend setup
8. Frontend setup
9. Environment variables
10. Database setup
11. Seed instructions
12. Running tests
13. API overview
14. Key engineering decisions
15. Performance considerations
16. AI-assisted development approach
17. Future improvements
18. Deployment links placeholders
19. Screenshots section placeholders
20. Demo video placeholder
21. License section

Writing Style:
- Professional and concise
- Clean markdown formatting
- Suitable for hiring managers/reviewers
- Avoid overly verbose explanations
- Focus on engineering decisions and product thinking
- Include emojis sparingly and professionally

Additionally:
- Include example API endpoints
- Include example .env variables
- Include commands in proper markdown code blocks
- Add badges for Rails, Next.js, TypeScript, PostgreSQL, and Material UI
- Add a “Highlights” section near the top
- Add a “Trade-offs & Decisions” section
- Mention why service objects were used only for insights logic

The README should feel like a polished production project submission rather than a tutorial.

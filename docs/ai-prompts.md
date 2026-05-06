### Generate The implementation plan

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

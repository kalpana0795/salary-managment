# Salary Management Tool — TDD Implementation Plan

> **Stack:** Ruby on Rails 8.1 (API-only) · Next.js 14 + MUI · SQLite (dev) / PostgreSQL (prod)
> **Test tools:** RSpec · FactoryBot · Shoulda-Matchers · React Testing Library · MSW
> **Cycle:** 🔴 Red → 🟢 Green → 🔵 Refactor — applied to every single feature.

---

## Table of Contents

1. [Phase 1 — Project Setup & Scaffolding](#phase-1)
2. [Phase 2 — Database Design & Employee Model](#phase-2)
3. [Phase 3 — Employee CRUD API](#phase-3)
4. [Phase 4 — Insights Engine (Service Layer)](#phase-4)
5. [Phase 5 — Seed Script](#phase-5)
6. [Phase 6 — Frontend: Employee Management](#phase-6)
7. [Phase 7 — Frontend: Insights Dashboard](#phase-7)
8. [Phase 8 — Deployment](#phase-8)
9. [Commit Strategy Reference](#commit-strategy)

---

<a name="phase-1"></a>
## Phase 1 — Project Setup & Scaffolding

### What to Build
- Rails 8.1 API-only app with RSpec, FactoryBot, Shoulda-Matchers, DatabaseCleaner
- Next.js 14 app with TypeScript, MUI v5, React Testing Library, MSW
- CORS configured for the Next.js dev origin
- Environment variable conventions (`.env`, `.env.test`)
- GitHub Actions CI running both test suites on every push

---

### 1.1 Backend Bootstrap

```bash
rails new salary-api --api --database=sqlite3 --skip-test
cd salary-api
```

**Gemfile additions:**

```ruby
group :development, :test do
  gem 'rspec-rails',               '~> 6.1'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'shoulda-matchers',          '~> 5.0'
end

gem 'rack-cors'
```

```bash
bundle install
rails generate rspec:install
```

**`spec/rails_helper.rb` — key additions:**

```ruby
Shoulda::Matchers.configure do |config|
  config.integrate { |with| with.test_framework(:rspec).and.library(:rails) }
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.use_transactional_fixtures = true
end
```

**`config/initializers/cors.rb`:**

```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('ALLOWED_ORIGINS', 'http://localhost:3000')
    resource '*', headers: :any, methods: %i[get post patch put delete options]
  end
end
```

---

### 1.2 Frontend Bootstrap

```bash
npx create-next-app@latest salary-ui --typescript --eslint --app
cd salary-ui
npm install @mui/material @emotion/react @emotion/styled @mui/icons-material
npm install --save-dev @testing-library/react @testing-library/jest-dom msw jest jest-environment-jsdom
```

---

### 1.3 TDD Cycle — Smoke Test

**🔴 RED — write the test first:**

```ruby
# spec/requests/health_spec.rb
RSpec.describe 'Health check', type: :request do
  it 'returns 200 with status ok' do
    get '/health'
    expect(response).to have_http_status(:ok)
    expect(JSON.parse(response.body)).to include('status' => 'ok')
  end
end
```

Run it — it fails (no route, no controller).

**🟢 GREEN — minimum code to pass:**

```ruby
# config/routes.rb
get '/health', to: 'health#index'

# app/controllers/health_controller.rb
class HealthController < ApplicationController
  def index
    render json: { status: 'ok' }
  end
end
```

**🔵 REFACTOR:** Nothing to refactor at this stage.

---

### 1.4 Commits

```
chore: bootstrap Rails API-only app with RSpec, FactoryBot, CORS
chore: bootstrap Next.js with MUI, RTL, MSW
test: add health check smoke test — RED
feat: add /health endpoint — GREEN
```

---

<a name="phase-2"></a>
## Phase 2 — Database Design & Employee Model

### What to Build
- `employees` table migration with UUID primary key, all columns, null constraints
- Three indexes: `country`, `job_title`, composite `(country, job_title)`
- `Employee` model with validations and a `before_validation` normalizer

---

### 2.1 Migration

```bash
rails generate migration CreateEmployees
```

```ruby
# db/migrate/YYYYMMDD_create_employees.rb
class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees, id: :uuid do |t|
      t.string  :full_name,  null: false
      t.string  :job_title,  null: false
      t.string  :country,    null: false
      t.integer :salary,     null: false
      t.string  :currency,   null: false, default: 'USD'
      t.string  :department
      t.timestamps
    end

    add_check_constraint :employees, 'salary > 0', name: 'salary_positive'

    add_index :employees, :country
    add_index :employees, :job_title
    add_index :employees, [:country, :job_title]
  end
end
```

```bash
rails db:migrate
```

---

### 2.2 TDD Cycle — Model

**🔴 RED — write all model tests first:**

```ruby
# spec/models/employee_spec.rb
RSpec.describe Employee, type: :model do
  subject { build(:employee) }

  # Validations
  it { is_expected.to validate_presence_of(:full_name) }
  it { is_expected.to validate_presence_of(:job_title) }
  it { is_expected.to validate_presence_of(:country) }
  it { is_expected.to validate_presence_of(:currency) }
  it { is_expected.to validate_numericality_of(:salary)
                        .is_greater_than(0)
                        .only_integer }

  # Normalizer
  describe 'before_validation normalizer' do
    it 'strips whitespace from full_name' do
      emp = build(:employee, full_name: '  Jane Doe  ')
      emp.valid?
      expect(emp.full_name).to eq('Jane Doe')
    end
  end

  # DB-level constraint (integration)
  describe 'DB null constraint' do
    it 'raises on missing full_name at DB level' do
      expect {
        Employee.insert({
          job_title: 'Dev', country: 'US', salary: 50_000,
          currency: 'USD', created_at: Time.current, updated_at: Time.current
        })
      }.to raise_error(ActiveRecord::NotNullViolation)
    end
  end
end
```

**🟢 GREEN:**

```ruby
# app/models/employee.rb
class Employee < ApplicationRecord
  before_validation :normalize_fields

  validates :full_name, :job_title, :country, :currency, presence: true
  validates :salary, numericality: { greater_than: 0, only_integer: true }

  private

  def normalize_fields
    self.full_name = full_name&.strip
  end
end
```

**🔵 REFACTOR:** Extract `normalize_fields` to a `Normalizable` concern if other models need it later.

---

### 2.3 Factory

```ruby
# spec/factories/employees.rb
FactoryBot.define do
  factory :employee do
    full_name  { Faker::Name.full_name }
    job_title  { Faker::Job.title }
    country    { Faker::Address.country_code }
    salary     { Faker::Number.between(from: 30_000, to: 250_000) }
    currency   { 'USD' }
    department { Faker::Commerce.department }
  end
end
```

---

### 2.4 Commits

```
feat: employees migration — UUID, null constraints, three indexes
test: Employee model validations + DB constraint tests — RED
feat: Employee model with validations and normalizer — GREEN
test: employee factory with Faker
```

---

<a name="phase-3"></a>
## Phase 3 — Employee CRUD API

### What to Build
- Centralized error handling in `ApplicationController`
- `EmployeesController` with `index`, `show`, `create`, `update`, `destroy`
- Pagination (`page`, `per_page`) and filtering (`country`, `job_title`) on `index`
- Consistent JSON API contract on every response

---

### 3.1 TDD Cycle — Error Handling First

Error handling must exist before any controller test runs, because every unhappy-path spec depends on it.

**🔴 RED:**

```ruby
# spec/requests/error_handling_spec.rb
RSpec.describe 'Error handling', type: :request do
  describe 'record not found' do
    it 'returns 404 with structured error' do
      get '/employees/non-existent-uuid'
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body.dig('error', 'code')).to eq('NOT_FOUND')
    end
  end

  describe 'parameter missing' do
    it 'returns 400 with structured error' do
      post '/employees', params: {}, as: :json
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body.dig('error', 'code')).to eq('PARAMETER_MISSING')
    end
  end
end
```

**🟢 GREEN:**

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound,      with: :not_found
  rescue_from ActiveRecord::RecordInvalid,        with: :unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :bad_request

  private

  def not_found(e)
    render json: error_response('NOT_FOUND', e.message), status: :not_found
  end

  def unprocessable_entity(e)
    render json: error_response('VALIDATION_ERROR', 'Validation failed',
                                e.record.errors.as_json), status: :unprocessable_entity
  end

  def bad_request(e)
    render json: error_response('PARAMETER_MISSING', e.message), status: :bad_request
  end

  def error_response(code, message, details = nil)
    payload = { error: { code:, message: } }
    payload[:error][:details] = details if details
    payload
  end
end
```

---

### 3.2 TDD Cycle — EmployeesController

**🔴 RED — full request spec before writing any controller action:**

```ruby
# spec/requests/employees_spec.rb
RSpec.describe 'Employees API', type: :request do

  # ── GET /employees ─────────────────────────────────────────────────────────
  describe 'GET /employees' do
    before { create_list(:employee, 15) }

    it 'returns 200 with paginated results' do
      get '/employees', params: { page: 1, per_page: 10 }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['data'].length).to eq(10)
      expect(body['meta']).to include('total_count', 'page', 'per_page')
    end

    it 'filters by country' do
      create(:employee, country: 'US')
      get '/employees', params: { country: 'US' }
      body = JSON.parse(response.body)
      expect(body['data'].map { |e| e['country'] }.uniq).to eq(['US'])
    end

    it 'filters by job_title' do
      create(:employee, job_title: 'Engineer')
      get '/employees', params: { job_title: 'Engineer' }
      body = JSON.parse(response.body)
      expect(body['data'].map { |e| e['job_title'] }.uniq).to eq(['Engineer'])
    end
  end

  # ── GET /employees/:id ──────────────────────────────────────────────────────
  describe 'GET /employees/:id' do
    let(:employee) { create(:employee) }

    it 'returns the employee' do
      get "/employees/#{employee.id}"
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['id']).to eq(employee.id)
      expect(body).to include('full_name', 'job_title', 'country', 'salary', 'currency')
    end

    it 'returns 404 for unknown id' do
      get '/employees/00000000-0000-0000-0000-000000000000'
      expect(response).to have_http_status(:not_found)
    end
  end

  # ── POST /employees ─────────────────────────────────────────────────────────
  describe 'POST /employees' do
    let(:valid_params) do
      { employee: { full_name: 'Jane Doe', job_title: 'Engineer',
                    country: 'US', salary: 90_000, currency: 'USD' } }
    end

    it 'creates and returns the employee with 201' do
      expect {
        post '/employees', params: valid_params, as: :json
      }.to change(Employee, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['full_name']).to eq('Jane Doe')
    end

    it 'returns 422 with validation errors on invalid params' do
      post '/employees', params: { employee: { full_name: '' } }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body.dig('error', 'code')).to eq('VALIDATION_ERROR')
      expect(body.dig('error', 'details')).to be_present
    end

    it 'returns 400 when employee key is missing' do
      post '/employees', params: {}, as: :json
      expect(response).to have_http_status(:bad_request)
    end
  end

  # ── PATCH /employees/:id ────────────────────────────────────────────────────
  describe 'PATCH /employees/:id' do
    let(:employee) { create(:employee) }

    it 'updates and returns the employee' do
      patch "/employees/#{employee.id}",
            params: { employee: { salary: 120_000 } }, as: :json
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['salary']).to eq(120_000)
    end

    it 'returns 422 on invalid update' do
      patch "/employees/#{employee.id}",
            params: { employee: { salary: -1 } }, as: :json
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  # ── DELETE /employees/:id ───────────────────────────────────────────────────
  describe 'DELETE /employees/:id' do
    let!(:employee) { create(:employee) }

    it 'deletes the employee and returns 204' do
      expect {
        delete "/employees/#{employee.id}"
      }.to change(Employee, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end
  end
end
```

**🟢 GREEN:**

```ruby
# config/routes.rb
Rails.application.routes.draw do
  get    '/health',     to: 'health#index'
  resources :employees, only: %i[index show create update destroy]
end
```

```ruby
# app/controllers/employees_controller.rb
class EmployeesController < ApplicationController
  before_action :set_employee, only: %i[show update destroy]

  def index
    employees = employees = Employee.select(
     :id, :full_name, :job_title, :country, :salary, :currency, :department
    )
    employees = employees.where(country: params[:country])   if params[:country].present?
    employees = employees.where(job_title: params[:job_title]) if params[:job_title].present?
    if params[:sort_by].present?
      order = params[:order] == 'desc' ? :desc : :asc
      employees = employees.order(params[:sort_by] => order)
    end


    page     = (params[:page]     || 1).to_i
    per_page = (params[:per_page] || 25).to_i.clamp(1, 100)
    total    = employees.count
    records  = employees.order(:full_name)
                        .offset((page - 1) * per_page)
                        .limit(per_page)

    render json: {
      data: records,
      meta: { total_count: total, page:, per_page:, total_pages: (total.to_f / per_page).ceil }
    }
  end

  def show
    render json: @employee
  end

  def create
    employee = Employee.create!(employee_params)
    render json: employee, status: :created
  end

  def update
    @employee.update!(employee_params)
    render json: @employee
  end

  def destroy
    @employee.destroy!
    head :no_content
  end

  private

  def set_employee
    @employee = Employee.find(params[:id])
  end

  def employee_params
    params.require(:employee)
          .permit(:full_name, :job_title, :country, :salary, :currency, :department)
  end
end
```

**🔵 REFACTOR:**
- Extract pagination logic to a `Paginatable` concern
- Extract filter logic to a query object (`EmployeeQuery`) if filter params grow beyond 3

---

### 3.3 API Contract Reference

| Endpoint | Success | Error cases |
|---|---|---|
| `GET /employees` | 200 + `{ data: [], meta: {} }` | — |
| `GET /employees/:id` | 200 + employee object | 404 |
| `POST /employees` | 201 + created object | 400, 422 |
| `PATCH /employees/:id` | 200 + updated object | 400, 404, 422 |
| `DELETE /employees/:id` | 204 no body | 404 |

---

### 3.4 Commits

```
test: error handling request spec — RED
feat: centralized error handling in ApplicationController — GREEN
test: full EmployeesController request spec — RED
feat: EmployeesController with pagination and filtering — GREEN
refactor: extract Paginatable concern
```

---

<a name="phase-4"></a>
## Phase 4 — Insights Engine (Service Layer)

### What to Build
- Four service objects under `app/services/insights/`
- Four `GET` endpoints under `/insights`
- All aggregation done in SQL — no Ruby-side looping over records

### Service Design Rule
Each service exposes one class method `call(params)` and returns a plain hash. No ActiveRecord objects leave the service.

---

### 4.1 Service: SalarySummaryService

**🔴 RED:**

```ruby
# spec/services/insights/salary_summary_service_spec.rb
RSpec.describe Insights::SalarySummaryService do
  before do
    create(:employee, country: 'US', salary: 60_000)
    create(:employee, country: 'US', salary: 90_000)
    create(:employee, country: 'US', salary: 120_000)
    create(:employee, country: 'CA', salary: 50_000)
  end

  context 'with country filter' do
    subject { described_class.call(country: 'US') }

    it 'returns correct min' do
      expect(subject[:min]).to eq(60_000)
    end

    it 'returns correct max' do
      expect(subject[:max]).to eq(120_000)
    end

    it 'returns correct avg' do
      expect(subject[:avg]).to be_within(1).of(90_000)
    end

    it 'returns correct count' do
      expect(subject[:count]).to eq(3)
    end
  end

  context 'without country filter' do
    it 'aggregates all employees' do
      result = described_class.call({})
      expect(result[:count]).to eq(4)
    end
  end

  context 'with no matching records' do
    it 'returns zeros' do
      result = described_class.call(country: 'ZZ')
      expect(result[:count]).to eq(0)
      expect(result[:min]).to be_nil
    end
  end
end
```

**🟢 GREEN:**

```ruby
# app/services/insights/salary_summary_service.rb
module Insights
  class SalarySummaryService
    def self.call(params = {})
      scope = Employee.all
      scope = scope.where(country: params[:country]) if params[:country].present?

      result = scope.pick(
        Arel.sql('MIN(salary)'),
        Arel.sql('MAX(salary)'),
        Arel.sql('ROUND(AVG(salary), 2)'),
        Arel.sql('COUNT(*)')
      )

      { min: result[0], max: result[1], avg: result[2], count: result[3] }
    end
  end
end
```

---

### 4.2 Service: SalaryByTitleService

**🔴 RED:**

```ruby
# spec/services/insights/salary_by_title_service_spec.rb
RSpec.describe Insights::SalaryByTitleService do
  before do
    create(:employee, country: 'US', job_title: 'Engineer', salary: 100_000)
    create(:employee, country: 'US', job_title: 'Engineer', salary: 120_000)
    create(:employee, country: 'US', job_title: 'Manager',  salary: 140_000)
  end

  it 'returns avg salary per job title for the country' do
    results = described_class.call(country: 'US')
    engineer = results.find { |r| r[:job_title] == 'Engineer' }
    expect(engineer[:avg_salary]).to be_within(1).of(110_000)
    expect(results.length).to eq(2)
  end

  it 'filters by job_title when provided' do
    results = described_class.call(country: 'US', job_title: 'Manager')
    expect(results.length).to eq(1)
    expect(results.first[:job_title]).to eq('Manager')
  end
end
```

**🟢 GREEN:**

```ruby
# app/services/insights/salary_by_title_service.rb
module Insights
  class SalaryByTitleService
    def self.call(params = {})
      scope = Employee.all
      scope = scope.where(country:   params[:country])   if params[:country].present?
      scope = scope.where(job_title: params[:job_title]) if params[:job_title].present?

      scope.group(:job_title)
           .order(:job_title)
           .pluck(
             :job_title,
             Arel.sql('ROUND(AVG(salary), 2)'),
             Arel.sql('COUNT(*)')
           )
           .map { |title, avg, count| { job_title: title, avg_salary: avg, count: } }
    end
  end
end
```

---

### 4.3 Service: DistributionService

**🔴 RED:**

```ruby
# spec/services/insights/distribution_service_spec.rb
RSpec.describe Insights::DistributionService do
  before do
    [25_000, 55_000, 75_000, 95_000, 150_000].each do |s|
      create(:employee, salary: s)
    end
  end

  it 'returns an array of bucket hashes' do
    results = described_class.call({})
    expect(results).to be_an(Array)
    expect(results.first).to include(:range, :count)
  end

  it 'places salaries in the correct bucket' do
    results = described_class.call({})
    bucket = results.find { |b| b[:range] == '50k–100k' }
    expect(bucket[:count]).to eq(2)
  end
end
```

**🟢 GREEN:**

```ruby
# app/services/insights/distribution_service.rb
module Insights
  class DistributionService
    BUCKETS = [
      { label: '<25k',      min: 0,       max: 24_999 },
      { label: '25k–50k',   min: 25_000,  max: 49_999 },
      { label: '50k–100k',  min: 50_000,  max: 99_999 },
      { label: '100k–150k', min: 100_000, max: 149_999 },
      { label: '150k+',     min: 150_000, max: Float::INFINITY },
    ].freeze

    def self.call(params = {})
      scope = Employee.all
      scope = scope.where(country: params[:country]) if params[:country].present?

      BUCKETS.map do |bucket|
        count = if bucket[:max] == Float::INFINITY
                  scope.where('salary >= ?', bucket[:min]).count
                else
                  scope.where(salary: bucket[:min]..bucket[:max]).count
                end
        { range: bucket[:label], count: }
      end
    end
  end
end
```

---

### 4.4 Service: OutliersService

**🔴 RED:**

```ruby
# spec/services/insights/outliers_service_spec.rb
RSpec.describe Insights::OutliersService do
  before do
    # Normal cluster around 70k
    create_list(:employee, 8, salary: 70_000)
    # One very high outlier
    @high = create(:employee, salary: 400_000)
    # One very low outlier
    @low  = create(:employee, salary: 5_000)
  end

  it 'flags employees more than 2 std deviations from the mean' do
    results = described_class.call({})
    outlier_ids = results.map { |r| r[:id] }
    expect(outlier_ids).to include(@high.id, @low.id)
  end

  it 'does not flag employees within normal range' do
    normal = Employee.where(salary: 70_000).first
    results = described_class.call({})
    expect(results.map { |r| r[:id] }).not_to include(normal.id)
  end
end
```

**🟢 GREEN:**

```ruby
# app/services/insights/outliers_service.rb
module Insights
  class OutliersService
    STDDEV_THRESHOLD = 2.0

    def self.call(params = {})
      scope = Employee.all
      scope = scope.where(country: params[:country]) if params[:country].present?

      salaries = scope.pluck(:salary).map(&:to_f)
      return [] if salaries.size < 2

      mean = salaries.sum / salaries.size
      variance = salaries.sum { |s| (s - mean)**2 } / (salaries.size - 1)
      stddev = Math.sqrt(variance)
    end
  end
end
```

> **SQLite note:** SQLite does not have a built-in `STDDEV` function. For development use `sqlite3-ruby` extensions or compute in Ruby over the aggregate. PostgreSQL in production handles it natively. Add a comment in the service explaining this divergence.

---

### 4.5 TDD Cycle — Insights Controllers

**🔴 RED — one spec covers all four endpoints:**

```ruby
# spec/requests/insights_spec.rb
RSpec.describe 'Insights API', type: :request do
  before do
    create(:employee, country: 'US', job_title: 'Engineer', salary: 80_000)
    create(:employee, country: 'US', job_title: 'Manager',  salary: 120_000)
    create(:employee, country: 'US', job_title: 'Engineer', salary: 100_000)
  end

  describe 'GET /insights/salary' do
    it 'returns min, max, avg, count' do
      get '/insights/salary', params: { country: 'US' }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to include('min', 'max', 'avg', 'count')
      expect(body['min']).to eq(80_000)
      expect(body['max']).to eq(120_000)
    end
  end

  describe 'GET /insights/salary-by-title' do
    it 'returns array of title + avg_salary + count' do
      get '/insights/salary-by-title', params: { country: 'US' }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to be_an(Array)
      expect(body.first).to include('job_title', 'avg_salary', 'count')
    end
  end

  describe 'GET /insights/distribution' do
    it 'returns salary distribution buckets' do
      get '/insights/distribution', params: { country: 'US' }
      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body).to be_an(Array)
      expect(body.first).to include('range', 'count')
    end
  end

  describe 'GET /insights/outliers' do
    it 'returns flagged employees' do
      get '/insights/outliers', params: { country: 'US' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to be_an(Array)
    end
  end
end
```

**🟢 GREEN:**

```ruby
# config/routes.rb (additions)
namespace :insights do
  get 'salary',          to: 'salary#index'
  get 'salary-by-title', to: 'salary_by_title#index'
  get 'distribution',    to: 'distribution#index'
  get 'outliers',        to: 'outliers#index'
end
```

```ruby
# app/controllers/insights/salary_controller.rb
module Insights
  class SalaryController < ApplicationController
    def index
      render json: Insights::SalarySummaryService.call(filter_params)
    end

    private

    def filter_params
      params.permit(:country)
    end
  end
end
```

> Create `SalaryByTitleController`, `DistributionController`, and `OutliersController` using the same pattern — delegate entirely to the service, render the result.

**🔵 REFACTOR:**
- Add a `InsightsController < ApplicationController` base class with shared `filter_params`
- All four insight controllers inherit from it

---

### 4.6 Commits

```
test: SalarySummaryService spec — RED
feat: SalarySummaryService — GREEN
test: SalaryByTitleService spec — RED
feat: SalaryByTitleService — GREEN
test: DistributionService spec — RED
feat: DistributionService — GREEN
test: OutliersService spec — RED
feat: OutliersService — GREEN
test: insights request specs — RED
feat: insights controllers + routes — GREEN
refactor: extract InsightsController base with shared filter_params
```

---

<a name="phase-5"></a>
## Phase 5 — Seed Script

### What to Build
- A `db/seeds.rb` that bulk-inserts 10,000 employees using `insert_all`
- Reads names from `db/seeds/first_names.txt` and `db/seeds/last_names.txt`
- Generates varied `country`, `job_title`, `salary`, and `currency` distributions for meaningful insights data

---

### 5.1 Seed Script Test

TDD seed logic via a dedicated spec that tests the helper module, not the `seeds.rb` file itself.

**🔴 RED:**

```ruby
# spec/lib/seed_generator_spec.rb
require 'rails_helper'
require Rails.root.join('lib/seed_generator')

RSpec.describe SeedGenerator do
  describe '.generate_batch' do
    subject(:batch) { described_class.generate_batch(count: 100) }

    it 'returns the requested number of records' do
      expect(batch.length).to eq(100)
    end

    it 'each record has all required fields' do
      record = batch.first
      expect(record).to include(:full_name, :job_title, :country,
                                 :salary, :currency, :created_at, :updated_at)
    end

    it 'salary is always greater than zero' do
      expect(batch.map { |r| r[:salary] }).to all(be > 0)
    end

    it 'produces varied countries' do
      expect(batch.map { |r| r[:country] }.uniq.length).to be > 1
    end
  end
end
```

**🟢 GREEN:**

```ruby
# lib/seed_generator.rb
module SeedGenerator
  COUNTRIES  = %w[US GB CA DE FR AU IN BR JP SG].freeze
  JOB_TITLES = ['Engineer', 'Senior Engineer', 'Manager', 'Director',
                 'Analyst', 'Designer', 'Product Manager', 'VP of Engineering'].freeze
  CURRENCIES = %w[USD GBP CAD EUR AUD INR BRL JPY SGD].freeze

  def self.generate_batch(count:)
    first_names = File.readlines(Rails.root.join('db/seeds/first_names.txt'), chomp: true)
    last_names  = File.readlines(Rails.root.join('db/seeds/last_names.txt'),  chomp: true)
    now         = Time.current

    Array.new(count) do
      country = COUNTRIES.sample
      {
        id:         SecureRandom.uuid,
        full_name:  "#{first_names.sample} #{last_names.sample}",
        job_title:  JOB_TITLES.sample,
        country:,
        salary:     rand(30_000..300_000),
        currency:   CURRENCIES[COUNTRIES.index(country)],
        department: %w[Engineering Product Design Operations Finance].sample,
        created_at: now,
        updated_at: now,
      }
    end
  end
end
```

**`db/seeds.rb`:**

```ruby
require Rails.root.join('lib/seed_generator')

puts "Seeding 10,000 employees..."
start_time = Time.now

batch_size  = 500
total       = 10_000

(total / batch_size).times do |i|
  Employee.insert_all(SeedGenerator.generate_batch(count: batch_size))
  print "."
end

puts "\nDone! #{Employee.count} employees created."
puts "Seeding completed in #{Time.now - start_time} seconds"
```

**🔵 REFACTOR:** Wrap `insert_all` in a transaction and add `on_duplicate` handling if seeds become idempotent in future.

---

### 5.3 Commits

```
test: SeedGenerator unit spec — RED
feat: SeedGenerator lib module — GREEN
feat: db/seeds.rb using insert_all in batches of 500
```

---

<a name="phase-6"></a>
## Phase 6 — Frontend: Employee Management

### What to Build
- `GET /employees` integration via a typed API client
- `EmployeeTable` component with MUI DataGrid, pagination, and filters
- `EmployeeFormModal` for create and edit
- `DeleteConfirmDialog`

---

### 6.1 API Client (typed)

```typescript
// lib/api.ts
const BASE = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:4000';

export async function apiFetch<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${BASE}${path}`, {
    headers: { 'Content-Type': 'application/json' },
    ...init,
  });
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    throw new ApiError(res.status, body?.error?.message ?? 'Request failed', body?.error);
  }
  return res.json() as Promise<T>;
}

export class ApiError extends Error {
  constructor(public status: number, message: string, public detail?: unknown) {
    super(message);
  }
}
```

---

### 6.2 TDD Cycle — EmployeeTable Component

**🔴 RED — write component test before the component:**

```typescript
// __tests__/components/EmployeeTable.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';
import EmployeeTable from '@/components/EmployeeTable';

const mockEmployees = [
  { id: '1', full_name: 'Jane Doe', job_title: 'Engineer', country: 'US',
    salary: 90000, currency: 'USD', department: 'Engineering' },
];

const server = setupServer(
  http.get('http://localhost:4000/employees', () =>
    HttpResponse.json({
      data: mockEmployees,
      meta: { total_count: 1, page: 1, per_page: 25, total_pages: 1 }
    })
  )
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('EmployeeTable', () => {
  it('renders employee rows after loading', async () => {
    render(<EmployeeTable />);
    expect(screen.getByRole('progressbar')).toBeInTheDocument();
    await waitFor(() => expect(screen.getByText('Jane Doe')).toBeInTheDocument());
    expect(screen.getByText('Engineer')).toBeInTheDocument();
  });

  it('shows error state when API fails', async () => {
    server.use(
      http.get('http://localhost:4000/employees', () =>
        HttpResponse.json({ error: { code: 'SERVER_ERROR' } }, { status: 500 })
      )
    );
    render(<EmployeeTable />);
    await waitFor(() =>
      expect(screen.getByText(/failed to load/i)).toBeInTheDocument()
    );
  });
});
```

**🟢 GREEN — minimal component to pass:**

```tsx
// components/EmployeeTable.tsx
'use client';
import { useEffect, useState } from 'react';
import { DataGrid, GridColDef } from '@mui/x-data-grid';
import { Alert, CircularProgress } from '@mui/material';
import { apiFetch } from '@/lib/api';

const columns: GridColDef[] = [
  { field: 'full_name',   headerName: 'Name',       flex: 1 },
  { field: 'job_title',   headerName: 'Job Title',  flex: 1 },
  { field: 'country',     headerName: 'Country',    width: 100 },
  { field: 'salary',      headerName: 'Salary',     width: 120, type: 'number' },
  { field: 'currency',    headerName: 'Currency',   width: 100 },
  { field: 'department',  headerName: 'Department', flex: 1 },
];

export default function EmployeeTable() {
  const [rows, setRows]       = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError]     = useState<string | null>(null);
  const [paginationModel, setPaginationModel] = useState({ page: 0, pageSize: 25 });
  const [total, setTotal]     = useState(0);

  useEffect(() => {
    setLoading(true);
    const { page, pageSize } = paginationModel;
    apiFetch<any>(`/employees?page=${page + 1}&per_page=${pageSize}`)
      .then(res => { setRows(res.data); setTotal(res.meta.total_count); })
      .catch(e => setError(e.message))
      .finally(() => setLoading(false));
  }, [paginationModel]);

  if (error) return <Alert severity="error">Failed to load employees: {error}</Alert>;

  return (
    <DataGrid
      rows={rows}
      columns={columns}
      rowCount={total}
      loading={loading}
      pageSizeOptions={[25, 50, 100]}
      paginationModel={paginationModel}
      paginationMode="server"
      onPaginationModelChange={setPaginationModel}
      getRowId={r => r.id}
      autoHeight
    />
  );
}
```

**🔵 REFACTOR:** Extract the `useEmployees` data-fetching hook so the component is presentation-only.

---

### 6.3 TDD Cycle — EmployeeFormModal

**🔴 RED:**

```typescript
// __tests__/components/EmployeeFormModal.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';
import EmployeeFormModal from '@/components/EmployeeFormModal';

const server = setupServer();
beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('EmployeeFormModal — create mode', () => {
  it('calls POST /employees and invokes onSuccess', async () => {
    const onSuccess = jest.fn();
    server.use(
      http.post('http://localhost:4000/employees', () =>
        HttpResponse.json({ id: '99', full_name: 'New Person' }, { status: 201 })
      )
    );
    render(<EmployeeFormModal open onClose={() => {}} onSuccess={onSuccess} />);
    fireEvent.change(screen.getByLabelText(/full name/i), { target: { value: 'New Person' } });
    fireEvent.change(screen.getByLabelText(/salary/i),    { target: { value: '80000' } });
    fireEvent.click(screen.getByRole('button', { name: /save/i }));
    await waitFor(() => expect(onSuccess).toHaveBeenCalled());
  });

  it('shows field errors returned by the API', async () => {
    server.use(
      http.post('http://localhost:4000/employees', () =>
        HttpResponse.json({
          error: { code: 'VALIDATION_ERROR', details: { salary: ['must be greater than 0'] } }
        }, { status: 422 })
      )
    );
    render(<EmployeeFormModal open onClose={() => {}} onSuccess={() => {}} />);
    fireEvent.click(screen.getByRole('button', { name: /save/i }));
    await waitFor(() =>
      expect(screen.getByText(/must be greater than 0/i)).toBeInTheDocument()
    );
  });
});
```

**🟢 GREEN:** Build the modal with controlled MUI `TextField` components, submit handler calling `apiFetch`, and field-level error display from the API response.

---

### 6.4 Commits

```
feat: typed API client with ApiError class
test: EmployeeTable component spec with MSW — RED
feat: EmployeeTable with DataGrid and server-side pagination — GREEN
refactor: extract useEmployees hook
test: EmployeeFormModal create + validation error specs — RED
feat: EmployeeFormModal — GREEN
test: DeleteConfirmDialog spec — RED
feat: DeleteConfirmDialog — GREEN
```

---

<a name="phase-7"></a>
## Phase 7 — Frontend: Insights Dashboard

### What to Build
- `InsightsPage` with a country `Select` driving all four panels
- `SummaryCards` (min / max / avg / count)
- `SalaryByTitleChart` (MUI X Charts bar chart)
- `DistributionChart` (histogram)
- `OutliersTable` (flagged employees)

---

### 7.1 TDD Cycle — SummaryCards

**🔴 RED:**

```typescript
// __tests__/components/SummaryCards.test.tsx
import { render, screen } from '@testing-library/react';
import SummaryCards from '@/components/insights/SummaryCards';

const data = { min: 30000, max: 200000, avg: 95000, count: 42 };

describe('SummaryCards', () => {
  it('renders all four stat cards', () => {
    render(<SummaryCards data={data} />);
    expect(screen.getByText('$30,000')).toBeInTheDocument();
    expect(screen.getByText('$200,000')).toBeInTheDocument();
    expect(screen.getByText('$95,000')).toBeInTheDocument();
    expect(screen.getByText('42')).toBeInTheDocument();
  });

  it('shows loading skeleton when data is null', () => {
    render(<SummaryCards data={null} />);
    expect(screen.getAllByTestId('stat-skeleton').length).toBeGreaterThan(0);
  });
});
```

**🟢 GREEN:** Build a grid of four MUI `Card` components. Use `Skeleton` when `data` is null.

---

### 7.2 TDD Cycle — InsightsPage Integration

**🔴 RED:**

```typescript
// __tests__/pages/InsightsPage.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { http, HttpResponse } from 'msw';
import { setupServer } from 'msw/node';
import InsightsPage from '@/app/insights/page';

const server = setupServer(
  http.get('http://localhost:4000/insights/salary',        () => HttpResponse.json({ min: 30000, max: 200000, avg: 90000, count: 5 })),
  http.get('http://localhost:4000/insights/salary-by-title', () => HttpResponse.json([])),
  http.get('http://localhost:4000/insights/distribution',   () => HttpResponse.json([])),
  http.get('http://localhost:4000/insights/outliers',       () => HttpResponse.json([])),
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

describe('InsightsPage', () => {
  it('loads and displays salary summary for all countries', async () => {
    render(<InsightsPage />);
    await waitFor(() => expect(screen.getByText('$30,000')).toBeInTheDocument());
  });

  it('refetches all panels when country filter changes', async () => {
    let called = 0;
    server.use(
      http.get('http://localhost:4000/insights/salary', ({ request }) => {
        called++;
        return HttpResponse.json({ min: 0, max: 0, avg: 0, count: 0 });
      })
    );
    render(<InsightsPage />);
    fireEvent.mouseDown(screen.getByLabelText(/country/i));
    fireEvent.click(screen.getByText('US'));
    await waitFor(() => expect(called).toBeGreaterThanOrEqual(2));
  });
});
```

**🟢 GREEN:** Build `InsightsPage` with a `useState` for `country`, pass it to all four data-fetching hooks, render each panel component.

---

### 7.3 Commits

```
test: SummaryCards with loading skeleton spec — RED
feat: SummaryCards component — GREEN
test: SalaryByTitleChart rendering spec — RED
feat: SalaryByTitleChart with MUI X BarChart — GREEN
test: InsightsPage integration spec with country filter — RED
feat: InsightsPage — GREEN
refactor: extract useInsights hooks family
```

---

<a name="phase-8"></a>
## Phase 8 — Deployment

### What to Build
- Production database switch: PostgreSQL via Railway
- Environment configuration for both Rails and Next.js
- CI/CD via GitHub Actions
- Seed in production after first deploy

---

### 8.1 Production Database Gemfile

```ruby
# Gemfile
gem 'sqlite3',   '~> 1.7', groups: [:development, :test]
gem 'pg',        '~> 1.5', group: :production
```

### 8.2 `config/database.yml`

```yaml
default: &default
  adapter: sqlite3
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: db/development.sqlite3

test:
  <<: *default
  database: db/test.sqlite3

production:
  adapter: postgresql
  url: <%= ENV['DATABASE_URL'] %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
```

### 8.3 GitHub Actions CI

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with: { bundler-cache: true }
      - run: bundle exec rails db:create db:schema:load
        env: { RAILS_ENV: test }
      - run: bundle exec rspec

  frontend:
    runs-on: ubuntu-latest
    defaults: { run: { working-directory: salary-ui } }
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20', cache: 'npm', cache-dependency-path: 'salary-ui/package-lock.json' }
      - run: npm ci
      - run: npm test -- --watchAll=false
```

### 8.4 Deploy Checklist

| Step | Command / Action |
|---|---|
| Push to GitHub | `git push origin main` |
| Create Railway project | Connect GitHub repo, add PostgreSQL plugin |
| Set env vars | `DATABASE_URL`, `RAILS_MASTER_KEY`, `ALLOWED_ORIGINS` |
| Run migrations | `rails db:migrate` via Railway shell |
| Seed production | `rails db:seed` via Railway shell |
| Deploy frontend | Connect `salary-ui` repo to Vercel, set `NEXT_PUBLIC_API_URL` |

### 8.5 OutliersService — PostgreSQL STDDEV note

```ruby
# The OutliersService uses STDDEV() which is only available in PostgreSQL.
# In development (SQLite), provide a Ruby fallback:
def self.stddev(scope)
  return scope.std_dev_salary if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'

  # SQLite fallback — compute in Ruby (acceptable for dev/test only)
  salaries = scope.pluck(:salary).map(&:to_f)
  return 0.0 if salaries.length < 2
  mean = salaries.sum / salaries.length
  Math.sqrt(salaries.sum { |s| (s - mean)**2 } / (salaries.length - 1))
end
```

---

### 8.6 Commits

```
chore: separate sqlite3 / pg gems by environment
chore: update database.yml for production PostgreSQL
ci: add GitHub Actions workflow for backend + frontend
chore: production env var documentation in README
```

---

<a name="commit-strategy"></a>
## Commit Strategy Reference

Every commit maps to a single TDD step. Use this convention:

| Prefix | When to use |
|---|---|
| `test:` | Adding or updating a failing test (RED step) |
| `feat:` | Adding production code to make tests pass (GREEN step) |
| `refactor:` | Cleaning up without changing behaviour (REFACTOR step) |
| `chore:` | Setup, config, tooling — no tests, no features |
| `fix:` | Correcting a bug discovered via a failing test |

### Example sequence for one feature

```
test: SalarySummaryService — min/max/avg/count with country filter — RED
feat: SalarySummaryService using SQL aggregation — GREEN
test: SalarySummaryService — empty result set returns zeros — RED
feat: handle nil result when no records match filter — GREEN
refactor: SalarySummaryService — extract scope builder to private method
```

This keeps the git log as a readable diary of TDD decisions — each red/green pair is atomic and reviewable in isolation.

---

## Quick Reference: Test → Code → Refactor Map

| Feature | Test file | Implementation |
|---|---|---|
| Health check | `spec/requests/health_spec.rb` | `HealthController` |
| Employee model | `spec/models/employee_spec.rb` | `Employee` model |
| Employee CRUD | `spec/requests/employees_spec.rb` | `EmployeesController` |
| Error handling | `spec/requests/error_handling_spec.rb` | `ApplicationController` |
| Salary summary | `spec/services/insights/salary_summary_service_spec.rb` | `Insights::SalarySummaryService` |
| Salary by title | `spec/services/insights/salary_by_title_service_spec.rb` | `Insights::SalaryByTitleService` |
| Distribution | `spec/services/insights/distribution_service_spec.rb` | `Insights::DistributionService` |
| Outliers | `spec/services/insights/outliers_service_spec.rb` | `Insights::OutliersService` |
| Insights API | `spec/requests/insights_spec.rb` | Insights controllers |
| Seed generator | `spec/lib/seed_generator_spec.rb` | `SeedGenerator` lib |
| Employee table | `__tests__/components/EmployeeTable.test.tsx` | `EmployeeTable` component |
| Form modal | `__tests__/components/EmployeeFormModal.test.tsx` | `EmployeeFormModal` component |
| Summary cards | `__tests__/components/SummaryCards.test.tsx` | `SummaryCards` component |
| Insights page | `__tests__/pages/InsightsPage.test.tsx` | `InsightsPage` page |

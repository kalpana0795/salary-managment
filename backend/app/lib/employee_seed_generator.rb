class EmployeeSeedGenerator
  ROLES = {
    'Software Engineer' => {
      salary_range: 80_000..140_000,
      department: 'Engineering'
    },
    'Senior Engineer' => {
      salary_range: 120_000..180_000,
      department: 'Engineering'
    },
    'Engineering Manager' => {
      salary_range: 160_000..240_000,
      department: 'Engineering'
    },
    'HR Manager' => {
      salary_range: 70_000..130_000,
      department: 'HR'
    },
    'Product Manager' => {
      salary_range: 110_000..190_000,
      department: 'Product'
    },
    'Designer' => {
      salary_range: 70_000..120_000,
      department: 'Design'
    },
    'QA Engineer' => {
      salary_range: 60_000..110_000,
      department: 'Engineering'
    },
    'Data Analyst' => {
      salary_range: 75_000..130_000,
      department: 'Analytics'
    }
  }.freeze

  COUNTRIES = [
    'India',
    'USA',
    'Germany',
    'Canada',
    'UK'
  ].freeze

  DEPARTMENTS = [
    'Engineering',
    'HR',
    'Product',
    'Design',
    'Operations'
  ].freeze

  COUNTRY_MULTIPLIERS = {
    'India' => 0.6,
    'USA' => 1.0,
    'Germany' => 0.9,
    'Canada' => 0.85,
    'UK' => 0.95
  }.freeze

  def initialize
    @first_names = load_names('first_names.txt')
    @last_names = load_names('last_names.txt')
  end

  def generate
    role, config = ROLES.to_a.sample
    country = COUNTRIES.sample

    base_salary = rand(config[:salary_range])
    salary = (base_salary * COUNTRY_MULTIPLIERS[country]).to_i

    {
      full_name: full_name,
      job_title: role,
      country: country,
      salary: salary,
      currency: 'USD',
      department: config[:department],
      created_at: Time.current,
      updated_at: Time.current
    }
  end

  private

  def load_names(file_name)
    File.readlines(
      Rails.root.join("db/seeds/data/#{file_name}"),
      chomp: true
    )
  end

  def full_name
    "#{@first_names.sample} #{@last_names.sample}"
  end
end

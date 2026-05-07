FactoryBot.define do
  factory :employee do
    full_name  { Faker::Name.name }
    job_title  { Faker::Job.title }
    country    { Faker::Address.country_code }
    salary     { Faker::Number.between(from: 30_000, to: 250_000) }
    currency   { 'USD' }
    department { Faker::Commerce.department }
  end
end
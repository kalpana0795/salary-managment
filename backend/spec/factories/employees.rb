FactoryBot.define do
  factory :employee do
    full_name { "MyString" }
    job_title { "MyString" }
    country { "MyString" }
    salary { 1 }
    currency { "MyString" }
    department { "MyString" }
  end
end

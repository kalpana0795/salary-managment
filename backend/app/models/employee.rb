# app/models/employee.rb

class Employee < ApplicationRecord
  ALLOWED_SORT_COLUMNS = %w[full_name salary country job_title]
 
  validates :full_name, :job_title, :country, :salary, :currency, presence: true
  validates :salary, numericality: { greater_than: 0 }
end

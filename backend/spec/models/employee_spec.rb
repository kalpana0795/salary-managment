require 'rails_helper'

RSpec.describe Employee, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      employee = Employee.new(
        full_name: 'John Doe',
        job_title: 'Engineer',
        country: 'India',
        salary: 50000,
        currency: 'USD'
      )
      expect(employee).to be_valid
    end

    it 'is invalid without full_name' do
      employee = Employee.new(full_name: nil)
      expect(employee).not_to be_valid
      expect(employee.errors[:full_name]).to include("can't be blank")
    end

    it 'is invalid with salary <= 0' do
      employee = Employee.new(
        full_name: 'John Doe',
        job_title: 'Engineer',
        country: 'India',
        salary: 0,
        currency: 'USD'
      )
      expect(employee).not_to be_valid
    end
  end

  describe 'db constraints' do
    it 'raises error when salary <= 0 at DB level' do
      expect {
        Employee.insert_all!([
          {
            full_name: 'John Doe',
            job_title: 'Engineer',
            country: 'India',
            salary: 0,
            currency: 'USD',
            created_at: Time.now,
            updated_at: Time.now
          }
        ])
      }.to raise_error(ActiveRecord::StatementInvalid)
    end
  end
end

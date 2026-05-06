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
end

# spec/services/insights/outliers_service_spec.rb

require 'rails_helper'

RSpec.describe Insights::OutliersService do
  describe '.call' do
    before do
      create(:employee,
            salary: 50_000,
            country: 'India',
            job_title: 'Software Engineer')

      create(:employee,
            salary: 51_000,
            country: 'India',
            job_title: 'Software Engineer')

      create(:employee,
            salary: 52_000,
            country: 'India',
            job_title: 'Software Engineer')

      create(:employee,
            salary: 53_000,
            country: 'India',
            job_title: 'Software Engineer')

      create(:employee,
            salary: 54_000,
            country: 'India',
            job_title: 'Software Engineer')

      create(:employee,
            salary: 2_000_000,
            country: 'India',
            job_title: 'Engineering Manager')

      create(:employee,
            salary: 70_000,
            country: 'USA',
            job_title: 'Software Engineer')

      create(:employee,
            salary: 80_000,
            country: 'USA',
            job_title: 'Product Manager')
    end

    it 'returns salary outliers' do
      result = described_class.call

      expect(result.count).to eq(1)

      expect(result.first.salary).to eq(2_000_000)
    end

    it 'filters outliers by country' do
      result = described_class.call(
        country: 'India'
      )

      expect(result.count).to eq(1)

      expect(result.first.salary).to eq(2_000_000)
    end

    it 'filters outliers by job title' do
      result = described_class.call(
        job_title: 'Engineering Manager'
      )

      expect(result.count).to eq(0)
    end

    it 'filters outliers by country and job title' do
      result = described_class.call(
        country: 'India',
        job_title: 'Software Engineer'
      )

      expect(result).to be_empty
    end

    it 'returns empty array when dataset has less than 2 salaries' do
      Employee.delete_all

      create(:employee, salary: 100_000)

      result = described_class.call

      expect(result).to eq([])
    end

    it 'returns empty result when no employees match filters' do
      result = described_class.call(
        country: 'Germany'
      )

      expect(result).to eq([])
    end
  end
end

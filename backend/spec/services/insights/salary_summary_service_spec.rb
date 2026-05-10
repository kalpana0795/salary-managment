require 'rails_helper'

RSpec.describe Insights::SalarySummaryService do
  describe '.call' do
    before do
      create(:employee,
             country: 'India',
             job_title: 'Engineer',
             salary: 80000)

      create(:employee,
             country: 'India',
             job_title: 'HR',
             salary: 120000)
      create(:employee,
             country: 'India',
             job_title: 'Engineer',
             salary: 100000)
      create(:employee,
             country: 'UK',
             job_title: 'HR',
             salary: 70000)
    end

    it 'returns min, max, and average salary for a job title in a country' do
      result = described_class.call(
        country: 'India',
        job_title: 'Engineer'
      )

      expect(result[:employee_count]).to eq(2)
      expect(result[:min_salary]).to eq(80000)
      expect(result[:max_salary]).to eq(100000)
      expect(result[:avg_salary]).to eq(90000.0)
    end

    it 'returns min, max, and average salary for a country' do
      result = described_class.call(country: 'India', job_title: '')

      expect(result[:employee_count]).to eq(3)
      expect(result[:min_salary]).to eq(80000)
      expect(result[:max_salary]).to eq(120000)
      expect(result[:avg_salary]).to eq(100000.0)
    end
  end
end

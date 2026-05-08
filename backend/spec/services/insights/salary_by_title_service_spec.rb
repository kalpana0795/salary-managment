require 'rails_helper'

RSpec.describe Insights::SalaryByTitleService do
  describe '.call' do
    before do
      create(:employee,
             country: 'India',
             job_title: 'Engineer',
             salary: 80000)

      create(:employee,
             country: 'India',
             job_title: 'Engineer',
             salary: 120000)
      create(:employee,
             country: 'India',
             job_title: 'HR',
             salary: 90000)
    end

    it 'returns average salary for a job title in a country' do
      result = described_class.call(
        country: 'India',
        job_title: 'Engineer'
      )

      expect(result[:avg_salary]).to eq(100000.0)
    end
  end
end

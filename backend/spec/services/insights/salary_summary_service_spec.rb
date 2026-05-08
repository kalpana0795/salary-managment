require 'rails_helper'

RSpec.describe Insights::SalarySummaryService do
  describe '.call' do
    before do
      create(:employee, country: 'India', salary: 50000)
      create(:employee, country: 'India', salary: 100000)
      create(:employee, country: 'India', salary: 150000)
    end

    it 'returns min, max, and average salary for a country' do
      result = described_class.call(country: 'India')

      expect(result[:min_salary]).to eq(50000)
      expect(result[:max_salary]).to eq(150000)
      expect(result[:avg_salary]).to eq(100000.0)
    end
  end
end

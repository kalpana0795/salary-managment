require 'rails_helper'

RSpec.describe Insights::DistributionService do
  describe '.call' do
    before do
      create(:employee, salary: 30000)
      create(:employee, salary: 70000)
      create(:employee, salary: 150000)
    end

    it 'groups salaries into buckets' do
      result = described_class.call

      expect(result).to be_an(Array)
      expect(result.first).to have_key(:range)
      expect(result.first).to have_key(:count)
    end
  end
end

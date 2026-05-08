require 'rails_helper'

RSpec.describe Insights::OutliersService do
  describe '.call' do
    before do
      10.times do
        create(:employee, salary: 100000)
      end

      create(:employee, salary: 1000000)
    end

    it 'returns salary outliers' do
      result = described_class.call

      expect(result).not_to be_empty
    end
  end
end

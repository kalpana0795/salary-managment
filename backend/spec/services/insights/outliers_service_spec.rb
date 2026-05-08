require 'rails_helper'

RSpec.describe Insights::OutliersService do
  describe '.call' do
    before do
      20.times do
        create(:employee, salary: rand(95_000..105_000))
      end
      create(:employee, salary: 100_000)
    end

    let!(:outlier_employee) do
      create(:employee, salary: 1_000_000)
    end

    it 'returns employees with salaries outside the normal range' do
      result = described_class.call

      expect(result).to include(outlier_employee)

      normal_salaries = result.map(&:salary)

      expect(normal_salaries).not_to include(100_000)
    end
  end
end

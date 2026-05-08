require 'rails_helper'

RSpec.describe EmployeeSeedGenerator do
  describe '#generate' do
    it 'returns valid employee attributes' do
      generator = described_class.new

      employee = generator.generate

      expect(employee[:full_name]).to be_present
      expect(employee[:salary]).to be > 0
      expect(employee[:country]).to be_present
    end
  end
end

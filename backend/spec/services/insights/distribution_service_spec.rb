# spec/services/insights/distribution_service_spec.rb

require 'rails_helper'

RSpec.describe Insights::DistributionService do
  describe '.call' do
    before do
      create(:employee,
             salary: 20_000,
             country: 'India',
             job_title: 'Software Engineer')

      create(:employee,
             salary: 40_000,
             country: 'India',
             job_title: 'Software Engineer')

      create(:employee,
             salary: 75_000,
             country: 'India',
             job_title: 'Product Manager')

      create(:employee,
             salary: 120_000,
             country: 'USA',
             job_title: 'Software Engineer')

      create(:employee,
             salary: 200_000,
             country: 'USA',
             job_title: 'Engineering Manager')
    end

    it 'returns salary distribution across all buckets' do
      result = described_class.call

      expect(result).to eq([
        {
          range: '<25k',
          count: 1,
        },
        {
          range: '25k–50k',
          count: 1,
        },
        {
          range: '50k–100k',
          count: 1,
        },
        {
          range: '100k–150k',
          count: 1,
        },
        {
          range: '150k+',
          count: 1,
        },
      ])
    end

    it 'filters distribution by country' do
      result = described_class.call(country: 'India')

      expect(result).to eq([
        {
          range: '<25k',
          count: 1,
        },
        {
          range: '25k–50k',
          count: 1,
        },
        {
          range: '50k–100k',
          count: 1,
        },
        {
          range: '100k–150k',
          count: 0,
        },
        {
          range: '150k+',
          count: 0,
        },
      ])
    end

    it 'filters distribution by job title' do
      result = described_class.call(
        job_title: 'Software Engineer'
      )

      expect(result).to eq([
        {
          range: '<25k',
          count: 1,
        },
        {
          range: '25k–50k',
          count: 1,
        },
        {
          range: '50k–100k',
          count: 0,
        },
        {
          range: '100k–150k',
          count: 1,
        },
        {
          range: '150k+',
          count: 0,
        },
      ])
    end

    it 'filters distribution by country and job title' do
      result = described_class.call(
        country: 'India',
        job_title: 'Software Engineer'
      )

      expect(result).to eq([
        {
          range: '<25k',
          count: 1,
        },
        {
          range: '25k–50k',
          count: 1,
        },
        {
          range: '50k–100k',
          count: 0,
        },
        {
          range: '100k–150k',
          count: 0,
        },
        {
          range: '150k+',
          count: 0,
        },
      ])
    end

    it 'returns zero counts when no employees match filters' do
      result = described_class.call(
        country: 'Germany'
      )

      expect(result).to eq([
        {
          range: '<25k',
          count: 0,
        },
        {
          range: '25k–50k',
          count: 0,
        },
        {
          range: '50k–100k',
          count: 0,
        },
        {
          range: '100k–150k',
          count: 0,
        },
        {
          range: '150k+',
          count: 0,
        },
      ])
    end
  end
end

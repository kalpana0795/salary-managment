# app/services/insights/distribution_service.rb

module Insights
  class DistributionService
    BUCKETS = [
      { label: '<25k',      min: 0,       max: 24_999 },
      { label: '25k–50k',   min: 25_000,  max: 49_999 },
      { label: '50k–100k',  min: 50_000,  max: 99_999 },
      { label: '100k–150k', min: 100_000, max: 149_999 },
      { label: '150k+',     min: 150_000, max: Float::INFINITY },
    ].freeze

    def self.call(country: nil, job_title: nil)
      scope = Employee.all
      scope = scope.where(country: country) if country.present?
      scope = scope.where(job_title: job_title) if job_title.present?

      BUCKETS.map do |bucket|
        count = if bucket[:max] == Float::INFINITY
                  scope.where('salary >= ?', bucket[:min]).count
                else
                  scope.where(salary: bucket[:min]..bucket[:max]).count
                end
        { range: bucket[:label], count: }
      end
    end
  end
end
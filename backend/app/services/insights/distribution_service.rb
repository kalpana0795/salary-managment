module Insights
  class DistributionService
    BUCKETS = [
      0..50_000,
      50_001..100_000,
      100_001..150_000,
      150_001..200_000
    ].freeze

    def self.call
      BUCKETS.map do |range|
        {
          range: "#{range.begin}-#{range.end}",
          count: Employee.where(salary: range).count
        }
      end
    end
  end
end

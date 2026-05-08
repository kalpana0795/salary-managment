module Insights
  class OutliersService
    STDDEV_THRESHOLD = 2

    def self.call(country: nil)
      scope = Employee.all
      scope = scope.where(country: country) if country.present?

      salaries = scope.pluck(:salary).map(&:to_f)

      return [] if salaries.size < 2

      mean = salaries.sum / salaries.size

      variance = salaries.sum do |salary|
        (salary - mean)**2
      end / (salaries.size - 1)

      stddev = Math.sqrt(variance)

      lower = mean - (STDDEV_THRESHOLD * stddev)
      upper = mean + (STDDEV_THRESHOLD * stddev)

      Employee.where('salary < ? OR salary > ?', lower, upper)
    end
  end
end

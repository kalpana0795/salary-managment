module Insights
  class OutliersService
    STDDEV_THRESHOLD = 2

    def self.call
      salaries = Employee.pluck(:salary).map(&:to_f)

      return [] if salaries.size < 2

      mean = salaries.sum / salaries.size

      variance = salaries.sum do |salary|
        (salary - mean)**2
      end / (salaries.size - 1)

      stddev = Math.sqrt(variance)

      lower = mean - (STDDEV_THRESHOLD * stddev)
      upper = mean + (STDDEV_THRESHOLD * stddev)

      Employee.where('salary < ? OR salary > ?', lower, upper)
              .select(:id, :full_name, :job_title, :salary)
    end
  end
end

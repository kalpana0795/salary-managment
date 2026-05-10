module Insights
  class SalarySummaryService
    def self.call(country: nil, job_title: nil)
      scope = Employee.all
      scope = scope.where(country: country) if country.present?
      scope = scope.where(job_title: job_title) if job_title.present?

      {
        employee_count: scope.size,
        min_salary: scope.minimum(:salary),
        max_salary: scope.maximum(:salary),
        avg_salary: scope.average(:salary).to_f.round(2)
      }
    end
  end
end

module Insights
  class SalarySummaryService
    def self.call(country:)
      employees = Employee.all
      employees = employees.where(country: country) if country.present?

      {
        employee_count: employees.size,
        min_salary: employees.minimum(:salary),
        max_salary: employees.maximum(:salary),
        avg_salary: employees.average(:salary).to_f.round(2)
      }
    end
  end
end

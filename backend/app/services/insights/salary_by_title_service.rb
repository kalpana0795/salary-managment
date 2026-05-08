module Insights
  class SalaryByTitleService
    def self.call(country:, job_title:)
      employees = Employee.where(
        country: country,
        job_title: job_title
      )

      {
        avg_salary: employees.average(:salary).to_f.round(2)
      }
    end
  end
end

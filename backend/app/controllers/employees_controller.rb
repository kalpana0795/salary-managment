# app/controllers/employees_controller.rb

class EmployeesController < ApplicationController
  def index
    page = params.fetch(:page, 1).to_i
    per_page = [params.fetch(:per_page, 10).to_i, 100].min

    employees = Employee.select(
      :id,
      :full_name,
      :job_title,
      :country,
      :salary,
      :currency,
      :department
    )

    employees = employees.where(country: params[:country]) if params[:country].present?
    employees = employees.where(job_title: params[:job_title]) if params[:job_title].present?

    total = employees.size

    employees = employees
                  .offset((page - 1) * per_page)
                  .limit(per_page)

    render json: {
      data: employees,
      meta: {
        page: page,
        per_page: per_page,
        total: total
      }
    }
  end
end

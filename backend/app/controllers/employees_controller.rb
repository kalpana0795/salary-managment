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

  def show
    employee = Employee.find(params[:id])

    render json: {
      data: employee
    }
  end

  def create
    employee = Employee.new(employee_params)

    if employee.save
      render json: {
        data: employee
      }, status: :created
    else
      render json: {
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid input',
          details: employee.errors
        }
      }, status: :unprocessable_entity
    end
  end

  def update
    employee = Employee.find(params[:id])

    if employee.update(employee_params)
      render json: {
        data: employee
      }
    else
      render json: {
        error: {
          code: 'VALIDATION_ERROR',
          message: 'Invalid input',
          details: employee.errors
        }
      }, status: :unprocessable_entity
    end
  end

  def destroy
    employee = Employee.find(params[:id])
    employee.destroy

    head :no_content
  end

  private

  def employee_params
    params.require(:employee).permit(
      :full_name,
      :job_title,
      :country,
      :salary,
      :currency,
      :department
    )
  end
end

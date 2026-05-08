# app/controllers/insights_controller.rb

class InsightsController < ApplicationController
  def salary
    result = Insights::SalarySummaryService.call(
      country: params[:country]
    )

    render json: {
      data: result
    }
  end

  def salary_by_title
    result = Insights::SalaryByTitleService.call(
      country: params[:country],
      job_title: params[:job_title]
    )

    render json: {
      data: result
    }
  end

  def distribution
    result = Insights::DistributionService.call

    render json: {
      data: result
    }
  end

  def outliers
    employees = Insights::OutliersService.call(
      country: params[:country]
    )

    render json: {
      data: employees.as_json(
        only: %i[
          id
          full_name
          job_title
          country
          salary
        ]
      )
    }
  end
end

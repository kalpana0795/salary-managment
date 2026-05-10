# app/controllers/insights_controller.rb

class InsightsController < ApplicationController
  def salary
    result = Insights::SalarySummaryService.call(
      country: params[:country],
      job_title: params[:job_title]
    )

    render json: {
      data: result
    }
  end

  def distribution
    result = Insights::DistributionService.call(
      country: params[:country],
      job_title: params[:job_title]
    )

    render json: {
      data: result
    }
  end

  def outliers
    page = params.fetch(:page, 1).to_i
    per_page = [params.fetch(:per_page, 10).to_i, 100].min

    employees = Insights::OutliersService.call(
      country: params[:country],
      job_title: params[:job_title]
    )

    total = employees.size

    employees = employees
                  .offset((page - 1) * per_page)
                  .limit(per_page)

    render json: {
      data: employees.as_json(
        only: %i[
          id
          full_name
          job_title
          country
          salary
        ]
      ),
      meta: {
        page: page,
        per_page: per_page,
        total: total
      }
    }
  end
end

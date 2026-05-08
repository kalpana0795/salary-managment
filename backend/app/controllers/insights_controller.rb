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
end

# app/controllers/application_controller.rb

class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    render json: {
      error: {
        code: 'NOT_FOUND',
        message: 'Record not found'
      }
    }, status: :not_found
  end
end

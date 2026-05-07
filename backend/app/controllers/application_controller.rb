# app/controllers/application_controller.rb

class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound,      with: :not_found
  rescue_from ActionController::ParameterMissing, with: :bad_request

  private

  def not_found(e)
    render json: error_response('NOT_FOUND', e.message), status: :not_found
  end

  def bad_request(e)
    render json: error_response('PARAMETER_MISSING', e.message), status: :bad_request
  end

  def error_response(code, message, details = nil)
    payload = { error: { code:, message: } }
    payload[:error][:details] = details if details
    payload
  end
end

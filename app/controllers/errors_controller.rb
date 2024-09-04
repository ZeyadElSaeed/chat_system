# app/controllers/errors_controller.rb
class ErrorsController < ApplicationController
  def not_found
    render json: { error: 'Not Found', message: 'The requested resource could not be found.' }, status: :not_found
  end

  def internal_server_error
    render json: { error: 'Internal Server Error', message: 'Something went wrong on our end.' }, status: :internal_server_error
  end
end

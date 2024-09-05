class ApplicationsController < ApplicationController

  def index
    application = Application.all
    if application.any?
      render json: application.as_json(only: [:token, :name, :chats_count]), status: :ok
    else
      render json: {error: "No Applications found"}, status: :not_found
    end
  end

  def create
    begin
      name = application_params[:name]
      token = generate_unique_token(name)
      application = Application.new({token:token, name:name})
      if application.valid?
        CreateApplicationJob.perform_later(token, name)
        render json: {token: token}, status: :ok
      else
        render json: {error: "Failed to create application", details: application.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActionController::ParameterMissing
      render json: {error: "Application parameters (name) are missing", status: :unprocessable_entity }, status: :unprocessable_entity
    end
  end

  def update
    begin
      name = application_params[:name]
      application = Application.find_by_token(params[:token])
      if application
        UpdateApplicationJob.perform_later(application, name)
        render json: {token: application.token, name: name}, status: :ok
      else
        render json: {error: "Failed to edit application. Perhaps not existing token: #{params[:token]}"}, status: :unprocessable_entity
      end
    rescue ActionController::ParameterMissing
      render json: {error: "Application parameters (name) are missing", status: :unprocessable_entity }, status: :unprocessable_entity
    end
  end

  def show
    application = Application.find_by_token(params[:token])
    render json: application.as_json(only: [:token, :name, :chats_count]), status: :ok
  end

  private
  def application_params
    params.require(:application).permit(:name)
  end

  def generate_unique_token(name)
    machine_id = Socket.gethostname
    uuid = SecureRandom.uuid
    timestamp = (Time.now.to_f * 1_000_000).to_i
    random_value = SecureRandom.hex(5)
    token = "#{name}-#{machine_id}-#{uuid}-#{timestamp}-#{random_value}"
    Digest::SHA256.hexdigest(token)
  end
  
end

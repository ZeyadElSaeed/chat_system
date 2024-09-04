class ChatsController < ApplicationController
  # GET /applications/:application_token/chats
  def index
    chats = Chat.find_by_token(params[:application_token])
    if chats.any?
      render json: chats, status: :ok
    else
      render json: {error: "No chats found for application token: #{params[:application_token]}"}, status: :not_found
    end
  end
  
  # GET /applications/:application_token/chats/:chat_number
  def show
    chats = Chat.find_by_token_chat_number(params[:application_token], params[:number])
    if chats.any?
      render json: chats, status: :ok
    else
      render json: {error: "No chat found for application token: #{params[:application_token]} and number: #{params[:number]}"}, status: :not_found
    end
  end

  # POST /applications/:application_token/chats
  def create
    application = Application.find_by_token(params[:application_token])
    if application
      CreateChatJob.perform_later(application)
      render json: {chat_number: application.chats_count + 1 }, status: :created
    else
      render json: {error: 'Application not found' }, status: :not_found
    end
  end

end

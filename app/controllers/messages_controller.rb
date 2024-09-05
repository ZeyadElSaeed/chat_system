class MessagesController < ApplicationController
  before_action :set_chat, only: [:search]

  # GET /applications/:application_token/chats/:chat_number/messages
  def index
    token = params[:application_token]
    chat_number = params[:chat_number]
    messages = Message.find_by_token_chat_number(token, chat_number)
    if messages.any?
      render json: messages, status: :ok
    else
      render json: {error: "No messages found for application token: #{token} and chat_number: #{chat_number}"}, status: :not_found
    end
  end

  # POST /applications/:application_token/chats/:chat_number/messages
  def create
    begin
      token = params[:application_token]
      chat_number = params[:chat_number]
      message_body = message_params[:body]
      chat = chats = Chat.find_by_token_chat_number(token, chat_number)
      message_number = chat.messages_count + 1
      CreateMessageJob.perform_later(chat, message_body)
      render json: { number: message_number, body: message_body }, status: :created
    rescue ActionController::ParameterMissing
      render json: { error: "Message parameters (body) are missing",status: :unprocessable_entity  }, status: :unprocessable_entity
    end
  end

  # GET /applications/:application_token/chats/:chat_number/messages/:message_number
  def show
    token = params[:application_token]
    chat_number = params[:chat_number]
    message_number = params[:message_number]
    message = Message.find_by_token_chat_number_message_number(token, chat_number, message_number)
    if message
      render json: message, status: :ok
    else
      render json: {error: "No messages found for application token: #{token} and chat: #{chat_number} and message: #{message_number}"}, status: :not_found
    end
  end

  def update
    token = params[:application_token]
    chat_number = params[:chat_number]
    message_number = params[:message_number]
    message = Message.find_by_token_chat_number_message_number(token, chat_number, message_number)
    if message
      UpdateMessageJob.perform_later(message, message_params[:body])
      render json: { number: message.number, body: message_params[:body] }, status: :ok
    else
      render json: { error: "Message not found with number #{params[:message_number]} in chat #{params[:chat_number]}" }, status: :not_found
    end
  end

  def search
    query = params[:query]
    results = Message.search(query, where: {chat_id: @chat.id}, fields: [:body], match: :word_middle) # Message.search(query, fields: [:body])
    if results.present?
      formatted_results = results.map do |result|
        {
          chat_id: result.chat_id,
          number: result.number,
          body: result.body
        }
      end
      render json: formatted_results
    else
      render json: { error: 'No results found' }, status: :not_found
    end


    # query = params[:query]
    # results = Message.search(query, where: { chat_id: params[:chat_number] }, fields: [:body])
    # render json: results 
  end
  
  private

  def set_chat
    @chat = Chat.find_by_token_chat_number(params[:application_token], params[:chat_number])
    unless @chat
      render json: { error: "Chat not found with number #{params[:chat_number]}"}, status: :not_found
    end
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
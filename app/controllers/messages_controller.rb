class MessagesController < ApplicationController
  before_action :set_application
  before_action :set_chat

  # GET /applications/:application_token/chats/:chat_number/messages
  def index
    render json: Message.find_by_token_chat_number(params[:application_token], params[:chat_number])
    # if @chat.messages.exists?
    #   @messages = @chat.messages.select(:number, :body)
    #   # render json: @messages.as_json(only: [:number, :body]), status: :ok
    #   render json:  @chat.messages, status: :ok

    # else
    #   render json: { error: "No messages found for this chat", status: :not_found }, status: :not_found
    # end
  end

  # POST /applications/:application_token/chats/:chat_number/messages
  def create
    begin
      @message = @chat.messages.new(message_params)
      @message.number = @chat.messages.count + 1
  
      if @message.save
        render json: { number: @message.number, body: @message.body }, status: :created
      else
        render json: { error: "Failed to create message", details: @message.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActionController::ParameterMissing
      render json: { error: "Message parameters (body) are missing",status: :unprocessable_entity  }, status: :unprocessable_entity
    end
  end

  # GET /applications/:application_token/chats/:chat_number/messages/:message_number
  def show
    render json: Message.find_by_token_chat_number_message_number(params[:application_token], params[:chat_number], params[:message_number])
    # @message = @chat.messages.find_by(number: params[:message_number])
    
    # if @message
    #   render json: { number: @message.number, body: @message.body }, status: :ok
    # else
    #   render json: { error: "Message not found with number #{params[:message_number]}", status: :not_found }, status: :not_found
    # end
  end

  def update
    begin
      @message = @chat.messages.find_by(number: params[:message_number])

    if @message.nil?
      render json: { error: "Message not found with number #{params[:message_number]} in chat #{params[:chat_number]}" }, status: :not_found
    elsif @message.update(message_params)
      render json: { number: @message.number, body: @message.body }, status: :ok
    else
      render json: { error: "Failed to create message", details: @message.errors.full_messages }, status: :unprocessable_entity
    end
    rescue ActionController::ParameterMissing
      render json: { error: "Message parameters (body) are missing",status: :unprocessable_entity  }, status: :unprocessable_entity
    end
  end

  def search
    query = params[:query]
    results = Message.search(query, where: {chat_id: @chat.id}, fields: [:body], match: :word_middle) # Message.search(query, fields: [:body])
    render json: results
    if results.present?
      formatted_results = results.map do |result|
        {
          number: result.number,
          body: result.body
        }
      end
      
    else
      # render json: { message: 'No results found' }, status: :ok
    end


    # query = params[:query]
    # results = Message.search(query, where: { chat_id: params[:chat_number] }, fields: [:body])
    # render json: results 
  end
  
  private

  def set_application
    Rails.logger.info("Params: #{params.inspect}")
    @application = Application.find_by(token: params[:application_token])
    unless @application
      render json: { error: "Application not found with token #{params[:application_token]}", status: :not_found }, status: :not_found
    end
  end

  def set_chat
    Rails.logger.info("Params: #{params.inspect}")
    @chat = @application.chats.find_by(number: params[:chat_number])
    unless @chat
      render json: { error: "Chat not found with number #{params[:chat_number]}", status: :not_found }, status: :not_found
    end
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
class CreateChatJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 2

  def perform(application)
    chat = application.chats.create
    if chat.persisted?
      Rails.logger.info("Chat created successfully: #{chat}")
    else
      Rails.logger.error("Failed to create chat for application: #{application}")
    end
  end

  def sidekiq_retries_exhausted
    Rails.logger.error("Application creation failed after retries: #{arguments}")
  end
end

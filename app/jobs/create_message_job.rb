class CreateMessageJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 2

  def perform(chat, message_body)
    message = chat.messages.new({body: message_body})
    message.number = chat.messages_count + 1
    if message.save
      Rails.logger.info("Message created successfully: #{message}")
      ReindexMessagesJob.perform_later
    else
      Rails.logger.error("Failed to create message for chat: #{chat}")
    end
  end

  def sidekiq_retries_exhausted
    Rails.logger.error("Message creation failed after retries: #{arguments}")
  end
end

class UpdateMessageJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 2

  def perform(message, body)
    if message.update({body: body})
      Rails.logger.info("Message body Successfully edited: #{message}")
      ReindexMessagesJob.perform_later
    else
      Rails.logger.error("Message body editing failed: #{message}")
    end
  end

  def sidekiq_retries_exhausted
    Rails.logger.error("Message editing failed after retries: #{arguments}")
  end
end

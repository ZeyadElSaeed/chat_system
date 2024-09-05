class ReindexMessagesJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 0

  def perform
    Message.reindex
  end
end

class ReindexMessagesJob < ApplicationJob
  queue_as :default

  def perform
    Message.reindex
  end
end

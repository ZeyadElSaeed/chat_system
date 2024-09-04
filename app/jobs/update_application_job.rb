class UpdateApplicationJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 2

  def perform(application, name)
    if application.update({name: name})
      Rails.logger.info("Application name Successfully edited: #{application}")
    else
      Rails.logger.error("Application name editing failed: #{application}")
    end
  end

  def sidekiq_retries_exhausted
    Rails.logger.error("Application editing failed after retries: #{arguments}")
  end
end

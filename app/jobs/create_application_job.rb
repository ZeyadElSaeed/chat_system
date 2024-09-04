class CreateApplicationJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 2

  def perform(token, name)
    application = Application.new({token:token, name:name})
    if application.save
      # You can handle success here, like sending notifications
      Rails.logger.info("Application Successfully created: #{application}")
    else
      Rails.logger.info("Application creation failed: #{application}")
    end
  end

  def sidekiq_retries_exhausted
    Rails.logger.error("Application creation failed after retries: #{arguments}")
  end
end

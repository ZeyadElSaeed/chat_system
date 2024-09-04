# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


require 'faker'

Application.destroy_all
Chat.destroy_all
Message.destroy_all

# Create 3 applications with sequential tokens
3.times do |i|
  application = Application.create!(
    name: "Application_#{i + 1}",
    token: "token_#{i + 1}"
  )

  # Create 10 chats for each application with sequential numbers
  10.times do |j|
    chat = application.chats.create!(
      number: j + 1,
      messages_count: 0
    )

    # Create 20 messages for each chat with sequential numbers and random body text
    20.times do |k|
      chat.messages.create!(
        number: k + 1,
        body: Faker::Lorem.sentence(word_count: 5)
      )
    end

    # Update messages_count after creating messages
    chat.update!(messages_count: chat.messages.count)
  end

  # Update chats_count after creating chats
  application.update!(chats_count: application.chats.count)
end

Message.reindex
puts "Seed data created successfully."
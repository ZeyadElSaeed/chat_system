class Message < ApplicationRecord
  belongs_to :chat, counter_cache: true

  validates :number, presence: true, uniqueness: { scope: :chat_id }
  validates :body, presence: true

  searchkick word_middle: [:body], callbacks: :async

  def self.find_by_token_chat_number(token, chat_number)
    Message.joins(chat: :application).where(applications: { token: token }, chats: {number: chat_number})
  end

  def self.find_by_token_chat_number_message_number(token, chat_number, message_number)
    Message.joins(chat: :application).where(applications: { token: token }, chats: {number: chat_number}, messages: {number: message_number}).take
  end
end

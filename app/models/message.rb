class Message < ApplicationRecord
  after_save :update_messages_count
  after_destroy :decrement_messages_count

  belongs_to :chat

  validates :number, presence: true, uniqueness: { scope: :chat_id }
  validates :body, presence: true

  searchkick word_middle: [:body]

  def self.find_by_token_chat_number(token, chat_number)
    Message.joins(chat: :application).where(applications: { token: token }, chats: {number: chat_number})
  end

  def self.find_by_token_chat_number_message_number(token, chat_number, message_number)
    Message.joins(chat: :application).where(applications: { token: token }, chats: {number: chat_number}, messages: {number: message_number})
  end

  private

  def update_messages_count
    chat.update(messages_count: chat.messages.count)
  end

  def decrement_messages_count
    chat.update(messages_count: chat.messages.count)
  end

end

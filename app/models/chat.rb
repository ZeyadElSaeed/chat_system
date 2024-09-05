class Chat < ApplicationRecord
  before_validation :set_chat_number, on: :create

  belongs_to :application, counter_cache: true
  has_many :messages, dependent: :destroy

  validates :number, presence: true, uniqueness: { scope: :application_id }

    def self.find_by_token(token)
      chats = Chat.joins(:application).where(applications: { token: token })
    end

    def self.find_by_token_chat_number(token, chat_number)
      Chat.joins(:application).where(applications: { token: token }, chats: {number: chat_number}).take
    end

  private
  def set_chat_number
    self.number = application.chats_count + 1
  end

end

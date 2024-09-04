class Chat < ApplicationRecord
  before_validation :set_chat_number, on: :create
  # after_save :update_chats_count
  # after_destroy :decrement_chats_count

  belongs_to :application, counter_cache: true
  has_many :messages, dependent: :destroy

  validates :number, presence: true, uniqueness: { scope: :application_id }

    def self.find_by_token(token)
      chats = Chat.joins(:application).where(applications: { token: token })
    end

    def self.find_by_token_chat_number(token, chat_number)
      Chat.joins(:application).where(applications: { token: token }, chats: {number: chat_number})
    end

  private
  def set_chat_number
    # last_chat_number = application.chats.maximum(:number) || 0
    # self.number = last_chat_number + 1
    self.number = application.chats_count + 1
  end

  # def update_chats_count
  #   application.update(chats_count: application.chats.count)
  # end

  # def decrement_chats_count
  #   application.update(chats_count: application.chats.count)
  # end
end

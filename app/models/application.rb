class Application < ApplicationRecord
    has_many :chats, dependent: :destroy

    validates :token, presence: true, uniqueness: true
    validates :name, presence: true

    # Find application by token
    def self.find_by_token(token)
        find_by(token: token)
    end
end

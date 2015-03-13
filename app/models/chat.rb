class Chat < ActiveRecord::Base
  has_many :messages
  has_many :chat_users, validate: true
  has_many :users, -> { uniq }, through: :chat_users, validate: true

  validate :validate_user_count

  private

    def validate_user_count
      errors.add(:users, "too few") if user_ids.count < 2
    end

end

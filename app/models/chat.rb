class Chat < ActiveRecord::Base
  has_many :messages
  has_and_belongs_to_many :users

  validate :validate_user_count

  private

    def validate_user_count
      errors.add(:users, "too few") if user_ids.count < 2
    end

end

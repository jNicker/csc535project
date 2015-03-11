class Message < ActiveRecord::Base
  belongs_to :chat
  belongs_to :user

  validates_presence_of :chat
  validates_presence_of :user
end

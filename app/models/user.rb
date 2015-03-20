class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise  :database_authenticatable,
          :registerable,
          :recoverable,
          :lockable
          # :trackable
          #:rememberable,
          #:confirmable,
          #:validatable

  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of :email, with: Devise.email_regexp

  validates_presence_of :username
  validates_uniqueness_of :username

  validates_presence_of :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of :password, within: Devise.password_length, allow_blank: true
  validates_format_of :password, with: /\A(?=.*?[#?!@$%^&*-]).{8,}\z/, message: 'is missing required characters #,?,!,@,$,%,^,&,*,-', if: :password_required?
  validates_format_of :password, with: /\A(?=.*?[A-Z]).{8,}\z/, message: 'is missing at least one uppercase character', if: :password_required?
  validates_format_of :password, with: /\A(?=.*?[0-9]).{8,}\z/, message: 'is missing at least one digit', if: :password_required?

  #has_many :chat_users
  #has_many :chats, through: :chat_users

  #has_many :messages, dependent: :destroy

  scope :without_user, ->(user) { where.not(id: user) }


  #scope :online, -> { where(last_seen: (30.minutes.ago)..Time.now) }

  # def stamp!
  #   if persisted?
  #     if self.last_seen.to_i < (Time.now - 5.minutes).to_i
  #       self.last_seen = DateTime.now
  #       self.save!
  #     end
  #   end
  # end

  protected

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

end

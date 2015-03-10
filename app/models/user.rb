class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :confirmable, :lockable

  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of :email, with: Devise.email_regexp

  validates_presence_of :username
  validates_uniqueness_of :username

  validates_presence_of :password, if: :password_required?
  validates_confirmation_of :password, if: :password_required?
  validates_length_of :password, within: Devise.password_length, allow_blank: true
  validates_format_of :password, with: /\A(?=.*?[#?!@$%^&*-]).{8,}\z/, message: 'is missing required characters #,?,!,@,$,%,^,&,*,-'
  validates_format_of :password, with: /\A(?=.*?[A-Z]).{8,}\z/, message: 'is missing at least one uppercase character'
  validates_format_of :password, with: /\A(?=.*?[0-9]).{8,}\z/, message: 'is missing at least one digit'

  protected

  def password_required?
    !persisted? || !password.nil? || !password_confirmation.nil?
  end

end

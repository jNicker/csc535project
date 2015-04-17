class UserMailer < ApplicationMailer

  def user_email(to_user, from_user, subject, body)
    @to_user = to_user
    @from_user = from_user
    @body = body
    mail(to: @to_user.email, from: @from_user.email, subject: subject)
  end

end

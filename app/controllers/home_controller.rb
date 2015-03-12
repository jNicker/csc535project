class HomeController < ApplicationController
  before_action :authenticate_user!, except: [:welcome]

  def index
    @message = Message.new(user_id: current_user)
    @logged_in_users = User.online.without_user(current_user)
    @chats = current_user.chats
  end

end

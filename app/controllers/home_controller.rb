class HomeController < ApplicationController
  before_action :authenticate_user!, except: [:welcome]

  def index
    @new_message = Message.new(user_id: current_user.id)
    @logged_in_users = User.online.without_user(current_user).order(last_seen: :desc)
    @chats = current_user.chats.order(updated_at: :desc)
  end

  def create
    @message = Message.new(message_params)
  end

  private

  def message_params
    params.require(:message).permit(:body, :user_id)
  end

end

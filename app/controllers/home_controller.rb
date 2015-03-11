class HomeController < ApplicationController
  before_action :authenticate_user!, except: [:welcome]

  def index
    @message = Message.new(user_id: current_user)
    @logged_in_users = User.online.without_user(current_user)
    @chats = current_user.chats
  end

#   def new
#     @chat = Home.new
#     @chats = Home.all
#   end

#   def create
#     respond_to do |format|
#       if current_user
#         @chat = Home.new(message_params)
#         format.js
#       else
#         format.html { redirect_to root_url }
#         format.js { render nothing: true }
#       end
#     end
#   end

#   def index
#     @homes = Home.all
#   end


# private
#   def message_params
#     params.require(:home).permit(:body)
#   end
end

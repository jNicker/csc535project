class HomesController < ApplicationController

  def new
    @chat = Home.new
    @chats = Home.all
  end

  def create
    respond_to do |format|
      if current_user
        @chat = Home.new(message_params)
        format.js
      else
        format.html { redirect_to root_url }
        format.js { render nothing: true }
      end
    end
  end

  def index
    @homes = Home.all
  end


private
  def message_params
    params.require(:home).permit(:body)
  end
end

class MessagesController < ApplicationController
  before_action :authenticate_user!


  def create
    respond_to do |format|
      @chat = Chat.find(message_params[:chat_id])
      if @chat.user_ids.include?(current_user.id)
        @message = Message.new(message_params)
        if @message.save
          flash.now[:success] = 'Your message was successfully sent'
        else
          flash.now[:error] = 'Your message could not be sent'
        end
        format.html { redirect_to root_url }
        format.js
      else
        format.html { redirect_to root_url }
        format.js { render nothing: true }
      end
    end
  end
  #before_action :set_chat, only: [:show, :edit, :update, :destroy]
  # before_action :set_message

  private

  # def set_message
  #   @message = Message.find(message_params[:id])
  # end

  def message_params
    params.require(:message).permit(:id, :body, :chat_id, :user_id)
  end

end

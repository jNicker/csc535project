class ChatsController < ApplicationController
  before_action :authenticate_user!
  #before_action :set_chat, only: [:show, :edit, :update, :destroy]
  before_action :set_chat, only: [:show]

  def show
    unless @chat.user_ids.include?(current_user.id)
      redirect_to home_index_path
    end
    @new_message = Message.new(chat_id: @chat.id, user_id: current_user.id)
  end

  def new
    @chat = Chat.new
  end

  def create
    chat_params[:user_ids] << current_user.id if chat_params[:user_ids] && !chat_params[:user_ids].include?(current_user.id)
    @chat = Chat.new(chat_params)
    respond_to do |format|
      #if @chat.persisted?
        # format.html { redirect_to @chat, notice: 'Chat already existed' }
        # format.json { render :show, status: :created, location: @chat}
      if @chat.save
        format.html { redirect_to @chat, notice: 'Chat was successfully created.' }
        format.json { render :show, status: :created, location: @chat }
      else
        format.html { render :new }
        format.json { render json: @chat.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_chat
    @chat = Chat.includes(:messages).find(params[:id])
  end

  def chat_params
    params.require(:chat).permit(:id, user_ids: [])
  end

end

class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    current_user.update_attributes(is_online: true, is_available: true)
    @this_user = current_user.attributes.extract!('id', 'username', 'is_available', 'is_online')
    @online_users = User.select(:id, :username, :is_available, :is_online).where.not(id: current_user.id);
    @new_message = Message.new()
    #@logged_in_users = User.online.without_user(current_user).order(last_seen: :desc)
    #@logged_in_users = User.where(is_online: true)
    #@chats = current_user.chats.order(updated_at: :desc)
    #@chats = Chat.all
  end

  def create
    params.permit!
    message = params[:message]
    message['created_at'] = 15.seconds.ago.to_formatted_s(:iso8601)
    @from_user = User.find(params[:message][:from_user])
    message[:from_user] = @from_user.username
    @to_user = User.find(params[:message][:to_user])
    message[:to_user] = @to_user.username
    FayeController.publish("/#{@from_user.username}", message)
    FayeController.publish("/#{@to_user.username}", message)
    respond_to do |format|
      format.js
      format.html { render nothing: true, status: 200 }
    end
  end

  def destroy
    #lets everyone know the the user is leaving
    params.permit!
    @to_user = User.find(params[:chatting_with]) if params[:chatting_with] != "0"
    @to_user.update_attributes(is_available: true) if @to_user
    current_user.update_attributes(is_online: false, is_available: false)
    FayeController.publish('/stopchat', [current_user.id, @to_user.id]) if @to_user
    FayeController.publish('/signoff', current_user.attributes.extract!('id'))
    respond_to do |format|
      format.html { render nothing: true, status: 200 }
    end
  end

  def send_email
    params.permit!
    @from_user = current_user
    @to_user = User.find(params[:user][:id])
    UserMailer.user_email(@to_user, @from_user, params[:email][:subject], params[:email][:body]).deliver_now
    flash.now[:success] = "Email sent to #{@to_user.username}"
    respond_to do |format|
      format.js
    end
  end

end

class HomeController < ApplicationController
  before_action :authenticate_user!, except: [:welcome]

  def index
    current_user.update_attributes(is_online: true, is_available: true)
    @this_user = current_user.attributes.extract!('id', 'username', 'is_available')
    @online_users = User.select(:id, :username, :is_available).where(is_online: true).where.not(id: current_user.id);
    @new_message = Message.new()
    #@logged_in_users = User.online.without_user(current_user).order(last_seen: :desc)
    #@logged_in_users = User.where(is_online: true)
    #@chats = current_user.chats.order(updated_at: :desc)
    #@chats = Chat.all
  end

  def create
    message = message_params
    message['created_at'] = 5.seconds.ago.to_formatted_s(:iso8601)
    FayeController.publish("/messages/#{message_params['to_user']}", message)
    FayeController.publish("/messages/#{message_params['from_user']}", message)
    respond_to do |format|
      format.html { render nothing: true, status: 200 }
    end
  end

  def destroy
    #lets everyone know the the user is leaving
    current_user.update_attributes(is_online: false, is_available: false)
    FayeController.publish('/signoff', current_user.attributes.extract!('id'))
    respond_to do |format|
      format.html { render nothing: true, status: 200 }
    end
  end

  private

  def message_params
    params.require(:message).permit!
  end

end

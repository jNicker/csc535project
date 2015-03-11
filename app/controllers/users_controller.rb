class UsersController < ApplicationController
  before_action :set_user, only: [:show]

  def show
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:id)
  end

end

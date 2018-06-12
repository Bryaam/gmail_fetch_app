class DashboardController < ApplicationController
  before_action :set_user, only: [:user_emails, :refresh_credentials]

  def index
    @users = User.includes(:credential).all
  end

  def user_emails
    begin
      service = GoogleApi.new @user

      @messages_list = service.get_emails DateTime.now - 1.hour

      p "-------------------------------"
      p @messages_list
      p "-------------------------------"
    rescue => exception
      # Set credentials to inactive state or refresh them
      p "-----------------------------------"
      p exception
      p "-----------------------------------"
    end
  end

  def refresh_credentials
    @user.credential.refresh!
    redirect_to dashboard_index_path
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end

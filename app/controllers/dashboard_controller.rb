class DashboardController < ApplicationController
  before_action :set_user, only: [:user_emails, :refresh_credentials]

  def index
    @users = User.includes(:credential).all
  end

  def user_emails
    begin
      service = GoogleApi.new @user

      before_date = DateTime.now
      after_date = @user.last_sync

      @messages_list = service.get_emails(after_date.to_i, before_date.to_i)

      p "-------------------------------"
      p @messages_list
      p "-------------------------------"
    rescue => exception
      # Set credentials to inactive state or refresh them
      Rails.logger.send(:error, exception)
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

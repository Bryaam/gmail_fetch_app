class DashboardController < ApplicationController
  before_action :set_user, only: [:user_emails, :refresh_credentials]

  def index
    @users = User.includes(:credential).all
  end

  def user_emails
    begin
      #credentials = Google::Auth::UserAuthorizer.new(
      #  ENV['GOOGLE_CLIENT_ID'],
      #  @user.credential.access_token,
      #  Google::Apis::GmailV1::AUTH_GMAIL_MODIFY
      #)

      service = GoogleApi.new @user

      @messages_list = service.get_emails

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

  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end

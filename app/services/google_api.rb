class GoogleApi
  require 'google/apis/gmail_v1'
  attr_accessor :service

  def initialize user
    credentials = AccessToken.new(user.credential.access_token, user.credential.expires_at)

    service = Google::Apis::GmailV1::GmailService.new
    service.client_options.application_name = 'Gmail Message Fetch'

    service.authorization = credentials

    @service = service
  end

  def get_emails
    return self.service.list_user_messages('me', max_results: 5, label_ids: ["INBOX"])
  end

end

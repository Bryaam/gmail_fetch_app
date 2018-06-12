class GoogleApi
  require 'google/apis/gmail_v1'
  require 'net/http'

  attr_accessor :service

  def initialize user
    credentials = AccessToken.new(user.credential.access_token, user.credential.expires_at)

    service = Google::Apis::GmailV1::GmailService.new
    service.client_options.application_name = 'Gmail Message Fetch'

    service.authorization = credentials

    @service = service
  end

  def get_emails before_date, after_date
    return self.service.list_user_messages('me', max_results: 100, label_ids: ["INBOX"], q: "after: #{after_date}, before: #{before_date}")
  end

  def get_email email
    return self.service.get_user_message('me', email.id, format: 'full')
  end

  def self.request_token credential
    url = URI("https://accounts.google.com/o/oauth2/token")
    Net::HTTP.post_form(url, credential.to_params)
  end

end

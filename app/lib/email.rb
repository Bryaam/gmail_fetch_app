class Email
  INBOUND_EMAIL_LABEL = 'inbound'.freeze
  OUTBOUND_EMAIL_LABEL = 'outbound'.freeze

  attr_accessor :id, :to, :from, :cc, :subject, :body, :sent_at,
                :id_type, :message_type, :parent_id, :direction

  def initialize(id, to, from, cc, subject, body, sent_at, direction)
    @id = id
    @to = to
    @from = from
    @cc = cc
    @subject = subject
    @body = body
    @sent_at = sent_at
    @id_type = 'google'
    @message_type = 'email'
    @parent_id = nil
    @direction = direction
  end

  def to_params
    {
      'id' => id,
      'to' => to,
      'from' => from,
      'cc' => cc,
      'subject' => subject,
      'body' => body,
      'sent_at' => sent_at,
      'id_type' => id_type,
      'message_type' => message_type,
      'parent_id' => parent_id,
      'direction' => direction
    }
  end

  def filter_email?
    health_iq_only_filter && duplicateds_filter && blacklist_filter
  end

  # Returns true if TO, FROM and CC only contains emails with health iq domain
  def health_iq_only_filter
    from_filter = from.split('@').last == ENV['HEALTH_IQ_DOMAIN']
    to_domains = Email.get_email_domains(to)
    to_filter = to_domains.count == to_domains.count(ENV['HEALTH_IQ_DOMAIN'])
    return from_filter && to_filter if cc.nil?
    cc_domains = Email.get_email_domains(cc)
    cc_filter = cc_domains.count == cc_domains.count(ENV['HEALTH_IQ_DOMAIN'])
    from_filter && to_filter && cc_filter
  end

  # Returns true if TO and FROM contains emails with health iq domain and the emails is inbound
  def duplicateds_filter
    from_filter = from.split('@').last == ENV['HEALTH_IQ_DOMAIN']
    to_domains = Email.get_email_domains(to)
    to_filter = to_domains.include? ENV['HEALTH_IQ_DOMAIN']
    from_filter && to_filter && direction == INBOUND_EMAIL_LABEL
  end

  # Returns true if there are emails in FROM attribute which are included on the blacklist
  def blacklist_filter
    blacklist = ENV['DOMAIN_BLACKLIST'].split(',')
    blacklist.include?(from.split('@').last)
  end

  def self.get_email_domains(emails)
    domains = []
    emails.split(',').each do |email|
      domains.append(email.split('@').last)
    end
    domains
  end
end

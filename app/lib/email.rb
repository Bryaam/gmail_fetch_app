class Email
  attr_accessor :id, :to, :from, :cc, :subject, :body, :sent_at, :id_type, :message_type, :parent_id, :direction

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
    puts self.to_params
    filter_1 = self.health_iq_only_filter
    filter_2 = self.duplicateds_filter
    filter_3 = self.blacklist_filter
    puts "Subject: #{self.subject}"
    puts "filter_1: #{filter_1}"
    puts "filter_2: #{filter_2}"
    puts "filter_3: #{filter_3}"
    return self.health_iq_only_filter && self.duplicateds_filter && self.blacklist_filter
  end

  # Returns true if TO, FROM and CC only contains emails with health iq domain
  def health_iq_only_filter
    from_filter = self.from.split("@").last == ENV['HEALTH_IQ_DOMAIN']

    to_domains = []
    self.to.split(",").each do |address|
      to_domains.append(address.split("@").last)
    end
    to_filter = to_domains.count == to_domains.count(ENV['HEALTH_IQ_DOMAIN'])
    if self.cc.nil?
      return from_filter && to_filter
    else
      cc_domains = []
      self.cc.split(",").each do |address|
        cc_domains.append(address.split("@").last)
      end
      cc_filter = cc_domains.count == cc_domains.count(ENV['HEALTH_IQ_DOMAIN'])
      return from_filter && to_filter && cc_filter
    end
  end

  # Returns true if TO and FROM contains emails with health iq domain and the emails is inbound
  def duplicateds_filter
    from_filter = self.from.split("@").last == ENV['HEALTH_IQ_DOMAIN']

    to_domains = []
    self.to.split(",").each do |address|
      to_domains.append(address.split("@").last)
    end
    to_filter = to_domains.include? ENV['HEALTH_IQ_DOMAIN']

    return from_filter && to_filter && self.direction == "Inbound"
  end

  # Returns true if there are emails in FROM attribute which are included on the blacklist
  def blacklist_filter
    blacklist = ENV['DOMAIN_BLACKLIST'].split(",")
    return blacklist.include?(self.from.split("@").last)
    # domains = []
    # self.from.split("@").last
    # self.from.split(",").each do |address|
    #   domains.append(address.split("@").last)
    # end
    # return (domains & ENV['DOMAIN_BLACKLIST']).empty?
  end
end

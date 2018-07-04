class EmailParser
  INBOUND_EMAIL_LABEL = 'inbound'.freeze
  OUTBOUND_EMAIL_LABEL = 'outbound'.freeze

  def self.parse(email_body, last_email_id)
    begin
      id = email_body.id
      return nil if EmailParser.reject_invalid_messages(email_body, last_email_id)
      labels = email_body.label_ids

      epoch_date = email_body.internal_date # This can be used to determine the last syncronized email

      payload = email_body.payload
      headers = payload.headers

      from = EmailParser.get_header_attribute(headers, 'From')
      to = EmailParser.get_header_attribute(headers, 'To')
      subject = EmailParser.get_header_attribute(headers, 'Subject')
      cc = EmailParser.get_header_attribute(headers, 'Cc')
      date = EmailParser.get_header_attribute(headers, 'Date')

      # Determining direction according to label
      direction = EmailParser.get_email_direction labels

      data = payload.parts[0].body.data # Will raise exception if no body is present
      data = data.to_str if data

      return Email.new(
        id,
        EmailParser.parse_email_lists(to),
        EmailParser.parse_email_lists(from),
        EmailParser.parse_email_lists(cc),
        subject,
        data,
        date,
        direction
      )
    rescue StandardError => exception
      # WIP
      Rails.logger.send(:error, exception)
      nil
    end
  end

  # Discard the email if belongs to CHAT category or has been processed the last time
  def self.reject_invalid_messages(email_body, last_email_id)
    return true if email_body.id == last_email_id || email_body.label_ids.include?('CHAT')
    false
  end

  def self.get_header_attribute(collection, key)
    collection.each do |element|
      return element.value if element.name == key
    end
    nil
  end

  # INBOX would be inbound
  # SENT would be outbound
  def self.get_email_direction(labels)
    return INBOUND_EMAIL_LABEL if labels.include? 'INBOX'
    return OUTBOUND_EMAIL_LABEL if labels.include? 'SENT'
    nil
  end

  def self.parse_email_lists(string)
    return nil if string.nil?
    list = []
    substrings = string.split(',')
    substrings.each do |substring|
      list.append(substring.split('<').last.split('>').first)
    end
    list.join(',')
  end
end

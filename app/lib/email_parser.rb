class EmailParser
  require "base64"
  INBOUND_EMAIL_LABEL = "inbound".freeze
  OUTBOUND_EMAIL_LABEL = "outbound".freeze

  def self.parse email_body, last_email_id
    begin
      id = email_body.id
      if(id == last_email_id)
        return nil
      else
        labels = email_body.label_ids

        epoch_date = email_body.internal_date # This can be used to determine the last syncronized email

        payload = email_body.payload

        headers = payload.headers

        from = EmailParser.get_header_attribute(headers, "From")
        to = EmailParser.get_header_attribute(headers, "To")
        subject = EmailParser.get_header_attribute(headers, "Subject")
        cc = EmailParser.get_header_attribute(headers, "Cc")
        date = EmailParser.get_header_attribute(headers, "Date")

        # Determining direction according to label
        direction = EmailParser.get_email_direction labels
        # INBOX would be inbound
        # SENT would be outbound

        data = payload.parts[0].body.data # Will raise exception if no body is present
        data = data.to_str if data

        registered_email = Email.new(
          id,
          EmailParser.parse_email_lists(to),
          EmailParser.parse_email_lists(from),
          EmailParser.parse_email_lists(cc),
          subject,
          data,
          date,
          direction
        )
        return registered_email
      end
    rescue => exception
      # WIP
      p exception
      return nil
    end
  end

  def self.get_header_attribute(collection, key)
    collection.each do |element|
      return element.value if element.name == key
    end
    return nil
  end

  def self.get_email_direction labels
    return INBOUND_EMAIL_LABEL if labels.include? "INBOX"
    return OUTBOUND_EMAIL_LABEL if labels.include? "SENT"
    return nil
  end

  def self.parse_email_lists string
    return nil if string.nil?
    list = []
    substrings = string.split(",")
    substrings.each do |substring|
      list.append(substring.split("<").last.split(">").first)
    end
    return list.join(",")
  end

end

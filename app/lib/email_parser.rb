class EmailParser
  require "base64"

  def self.parse email_body, last_email_id
    begin
      id = email_body.id

      p "Impresion de comparacion de ids"
      p id
      p last_email_id
      if(id == last_email_id)
        p "Entra al NULO"
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



        #body = Base64.decode64(data)
        p "XXXXXXXXXXXXXXXXXXXX"
        # puts "id: #{id}"
        # puts "from: #{from}"
        # puts "to: #{to}"
        # puts "subject: #{subject}"
        # puts "cc: #{cc}"
        # puts "date: #{date}"
        # puts "direction: #{direction}"
        # puts "body: #{data}"
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
        #puts registered_email.to_params
        return registered_email
        p "XXXXXXXXXXXXXXXXXXXX"
      end
    rescue => exception
      p exception
      return nil
    end
  end

  def self.get_header_attribute(collection, key)
    collection.each do |element|
      return element.value if element.name == key
    end
    nil
    #attribute = collection.find{|key| key.name == key }
    #attribute.value
  end

  def self.get_email_direction labels
    return "Inbound" if labels.include? "INBOX"
    return "Outbound" if labels.include? "SENT"
    nil
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

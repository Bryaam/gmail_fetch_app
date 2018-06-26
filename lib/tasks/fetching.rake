# frozen_string_literal: true

namespace :fetching do
  desc 'Retrieves every user email list'
  task email_retrieve: :environment do
    User.all.each do |user|
      puts "Checking user #{user.email}"
      user.credential.refresh! if user.credential.expired?
      service = GoogleApi.new user

      emails = user.retrieve_emails(service)

      # path = "running_tasks/pids/#{user.id}"
      # content = 'Processing'

      # File.open(path, 'w+') do |f|
      #  f.write(content)
      # end

      begin
        if emails&.messages
          emails.messages.reverse_each do |email|
            current_email = service.get_email email
            valid_email = EmailParser.parse(current_email, user.last_email_id)
            if valid_email
              user.update_attributes(last_sync: Time.parse(valid_email.sent_at),
                                     last_email_id: valid_email.id)
              unless valid_email.filter_email?
                # Send WIP

              end
            end
          end
        end
      rescue StandardError => exception
        # WIP
        puts exception
        Rails.logger.send(:error, exception)
      end
    end
  end

  desc 'Only to test'
  task test_rake: :environment do
    puts 'Test passed'
  end
end

namespace :fetching do
  desc "Retrieves every user email list"
  task email_retrieve: :environment do
    User.all.each do |user|
      user.credential.refresh! if user.credential.expired?
      service = GoogleApi.new user
      before_date = DateTime.now - 1.day
      after_date = DateTime.now
      emails = service.get_emails(after_date.to_i, before_date.to_i)

      path = "running_tasks/pids/#{user.id}"
      content = "Processing"

      File.open(path, "w+") do |f|
        f.write(content)
      end

      puts user.email
      puts emails
      puts "-------------------------------------------"
      unless emails.messages.nil?
        emails.messages.each do |email|
          current_email = service.get_email email
          puts current_email.to_json
        end
      end
      puts "-------------------------------------------"
    end
  end

end

# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
# Rails Logger setup
Rails.logger = Logger.new(STDOUT)

namespace :graylog do
  namespace :integration do
    desc 'Associate all applications with existing Graylog Streams. The task is idempotent'
    task sync: :environment do
      abort('GRAYLOG_ENABLED must be present') unless ENV['GRAYLOG_ENABLED'] == 'true'

      client = GraylogAPI::Client.new

      puts "Retrieving all streams for #{ENV['GRAYLOG_API_URI']}"
      response = client.get('/streams')

      raise response.message unless response.successful?

      updated_apps = GraylogAPI::StreamMatcher.new.sync_apps_with_existing_streams(response.body[:streams])

      Rails.logger.info "Process complete. Updated #{updated_apps} of #{App.count} apps"
    end
  end
end

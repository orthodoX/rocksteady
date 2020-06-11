module GraylogAPI
  class StreamMatcher
    def sync_apps_with_existing_streams(all_streams)
      updated_apps = 0

      App.all.each do |app|
        next if app.graylog_stream.present?

        app.assign_attributes(validate_stream: true)

        stream_info = all_streams.find do |stream|
          rule_set = stream['rules'].find { |set| set['value'] == app.name }

          stream['title'] == app.name && rule_set.present?
        end

        next Rails.logger.warn "Could not find an existing stream for #{app.name}" unless stream_info.present?

        app.build_graylog_stream
        app.graylog_stream.update(
          id: stream_info['id'],
          name: app.name,
          rule_value: app.name,
          index_set_id: stream_info['index_set_id']
        )

        next Rails.logger.warn "Could not update #{app.name}" unless app.save
        updated_apps += 1

        Rails.logger.info "#{app.name} associated with stream: #{app.graylog_stream.id}"
      end

      updated_apps
    end
  end
end

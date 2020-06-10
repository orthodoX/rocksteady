require 'rails_helper'

RSpec.describe GraylogAPI::StreamMatcher do
  subject(:updater) { described_class.new }

  let(:graylog_stream) { GraylogStream.new(id: '1', name: 'app-title-1', rule_value: 'app-title-1', index_set_id: '1') }
  let(:all_streams) {
    [
      {
        "id"=>"stream_id_1",
        "description"=>"some-description",
        "rules"=>
         [{"field"=>"tag", "stream_id"=>"stream_id_1", "description"=>"", "id"=>"some_id", "type"=>6, "inverted"=>false, "value"=>"app-title-1"},
          {"field"=>"tag", "stream_id"=>"stream_id_1", "description"=>"", "id"=>"some_id", "type"=>6, "inverted"=>true, "value"=>"app-title-1-migrations"}],
        "title"=>"app-title-1",
        "index_set_id"=>"index_set_id_1",
      },
      {
        "id"=>"stream_id_2",
        "description"=>"some-description",
        "rules"=>
         [{"field"=>"tag", "stream_id"=>"stream_id_2", "description"=>"", "id"=>"some_id", "type"=>6, "inverted"=>false, "value"=>"app-title-2"},
          {"field"=>"tag", "stream_id"=>"stream_id_2", "description"=>"", "id"=>"some_id", "type"=>6, "inverted"=>true, "value"=>"app-title-2-migrations"}],
        "title"=>"app-title-2",
        "index_set_id"=>"index_set_id_2",
      }
    ]
  }

  def existing_app(name: 'app-title-1', stream: graylog_stream)
    App.create!(
      { name: name, repository_name: 'test', job_spec: 'job {}', graylog_stream: stream }
    )
  end

  describe '#sync_apps_with_existing_streams' do
    context 'when a graylog_stream association is already present on all apps' do
      it 'returns 0' do
        existing_app

        expect(updater.sync_apps_with_existing_streams(all_streams)).to eq(0)
      end
    end

    context 'when all apps have no association and the streams are present in Graylog' do
      it 'returns the number of updated apps' do
        existing_app(stream: nil)
        existing_app(name: 'app-title-2', stream: nil)

        expect(updater.sync_apps_with_existing_streams(all_streams)).to eq(2)
      end

      it 'associates all apps with graylog_streams' do
        existing_app(stream: nil)
        existing_app(name: 'app-title-2', stream: nil)

        updater.sync_apps_with_existing_streams(all_streams)

        stream_ids = App.all.map {|app| app.graylog_stream.id }

        expect(stream_ids).to match_array(['stream_id_1', 'stream_id_2'])
      end
    end

    context 'when all apps have no association and some streams are present in Graylog' do
      it 'returns the number of updated apps' do
        existing_app(stream: nil)
        existing_app(name: 'not-present-1', stream: nil)

        expect(updater.sync_apps_with_existing_streams(all_streams)).to eq(1)
      end

      it 'logs a warning' do
        allow(Rails.logger).to receive(:warn)

        existing_app(stream: nil)
        existing_app(name: 'not-present-1', stream: nil)

        updater.sync_apps_with_existing_streams(all_streams)

        expect(Rails.logger).to have_received(:warn).with(
          'Could not find an existing stream for not-present-1'
        )
      end
    end
  end
end

require 'rails_helper'

RSpec.describe AppIndex do
  let(:app) {
    {
      name: 'testapp',
      repository_name: 'rocksteady',
      job_spec: 'job {}'
    }
  }

  describe '#repos_html' do
    it 'returns a list of apps' do
      App.create!(app)
      expect(described_class.new.repos_html.count).to eq(1)
    end

    it 'sorts the apps alphabetically by repository name' do
      App.create!(app.merge(name: 'last', repository_name: 'last'))
      App.create!(app.merge(name: 'first', repository_name: 'first'))

      app_names = described_class.new.repos_html.map(&:first)

      expect(app_names).to eq(['first', 'last'])
    end
  end

  describe '#repos_json' do
    it 'returns all apps unsorted' do
      App.create!(app.merge(name: 'last', repository_name: 'last'))
      App.create!(app.merge(name: 'first', repository_name: 'first'))

      app_names = described_class.new.repos_json.map { |app| app[:name] }

      expect(app_names).to eq(['last', 'first'])
    end
  end
end

require 'rails_helper'

RSpec.describe App do
  def app_named(name)
    App.create(name: name, repository_name: 'test', job_spec: '{}')
  end

  describe 'name' do
    it 'cannot contain spaces' do
      expect(app_named('test app').errors.messages[:name]).to include('is invalid')
    end

    it 'cannot contain uppercase characters' do
      expect(app_named('Testapp').errors.messages[:name]).to include('is invalid')
    end

    it 'cannot contain symbols' do
      expect(app_named('te$tapp').errors.messages[:name]).to include('is invalid')
    end

    it 'can contain lowercase characters, digits, and hyphens' do
      expect(app_named('test-app').errors.messages[:name]).to be_empty
    end

    it 'is unique' do
      app_named('test-app')

      expect(app_named('test-app').errors.messages[:name]).to include('has already been taken')
    end
  end
end

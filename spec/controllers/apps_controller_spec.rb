require 'rails_helper'

RSpec.describe AppsController, type: :controller do
  let(:app) {
    {
      name: 'testapp',
      description: 'test description',
      repository_name: 'rocksteady',
      auto_deploy: false,
      auto_deploy_branch: 'main',
      job_spec: 'job "testapp" { task "testapp" {} }',
      image_source: 'ecr'
    }
  }

  describe '#index' do
    context 'when HTML format' do
      render_views

      it 'renders the index template' do
        App.create!(app)
        get :index
        expect(response.body).to include('appscontent')
      end

      it 'displays apps' do
        App.create!(app)
        get :index
        expect(response.body).to include('testapp')
      end

      it 'informs user if no apps' do
        get :index
        expect(response.body).to include('No apps')
      end
    end

    context 'when JSON format' do
      before { App.create!(app) }

      it 'returns success status' do
        get :index, as: :json
        expect(response.status).to eq(200)
      end

      it 'returns apps' do
        get :index, as: :json
        expect(JSON.parse(response.body)).to be_a(Array)
      end
    end
  end

  describe '#show' do
    render_views

    before do
      App.create!(app)
      get :show, params: { id: 'testapp' }
    end

    it 'renders the deploy template' do
      expect(response.body).to include("<a class='active nav-link' href='/apps/testapp'>Deploy</a>")
    end

    it 'shows app' do
      expect(response.body).to include('testapp')
    end

    it 'throws a 404 if app not found' do
      expect { get :show, params: { id: 'inexistent' } }.to raise_error(
        ActiveRecord::RecordNotFound
      )
    end
  end

  describe '#job_spec' do
    render_views

    before do
      App.create!(app)
      get :job_spec, params: { id: 'testapp' }
    end

    it 'renders the job_spec template' do
      expect(response.body).to include('code-highlight')
    end

    it 'displays job spec' do
      expect(response.body).to include('<span class="nx">job</span>')
    end

    it 'throws a 404 if app not found' do
      expect { get :job_spec, params: { id: 'inexistent' } }.to raise_error(
        ActiveRecord::RecordNotFound
      )
    end
  end

  describe '#details' do
    render_views

    def render_details(attributes = {})
      App.create!(app.merge(attributes))
      get :details, params: { id: 'testapp' }
    end

    it 'displays app details' do
      render_details
      expect(response.body).to include('test description')
    end

    it 'makes description optional' do
      render_details(description: nil)
      expect(response.body).to_not include('<dt>Description</dt>')
    end

    it 'formats created at' do
      render_details(created_at: Time.utc(1999, 12, 31))
      expect(response.body).to match(/1999\-12\-31 00\:00\:00 UTC \(\w+ \d+ years ago/)
    end

    it 'formats updated at' do
      render_details(updated_at: Time.utc(1999, 12, 31))
      expect(response.body).to match(/1999\-12\-31 00\:00\:00 UTC \(\w+ \d+ years ago/)
    end

    it 'throws a 404 if app not found' do
      expect { get :details, params: { id: 'inexistent' } }.to raise_error(
        ActiveRecord::RecordNotFound
      )
    end
  end

  describe '#nomad' do
    render_views

    before do
      App.create!(app)
      get :nomad, params: { id: 'testapp' }
    end

    it 'shows Nomad status' do
      expect(response.body).to include('AllocationStatus')
    end

    it 'throws a 404 if app not found' do
      expect { get :nomad, params: { id: 'inexistent' } }.to raise_error(
        ActiveRecord::RecordNotFound
      )
    end
  end

  describe '#new' do
    render_views

    it 'renders the new template' do
      get :new
      expect(response.body).to include('Create an app')
    end

    it 'does not show Graylog UI elements' do
      get :new
      expect(response.body).to_not include('app_with_stream')
    end

    it 'shows Graylog UI elements if enabled' do
      enable_graylog
      get :new
      expect(response.body).to include('app_with_stream')
    end
  end

  describe '#create' do
    def create_app(attributes = {})
      post :create, params: { app: app.merge(attributes) }
    end

    it 'creates a new app' do
      create_app
      expect(App).to exist
    end

    it 'creates a new app with a Graylog stream' do
      enable_graylog
      stub_stream_creation
      create_app(with_stream: '1')
      expect(App.last.graylog_stream).to_not be_nil
    end

    it 'does not create a new app with validation errors' do
      create_app(name: nil)
      expect(App).to_not exist
    end

    it 'does not create a new app with stream validation errors' do
      enable_graylog
      stub_stream_creation_failure
      create_app(with_stream: '1')
      expect(App).to_not exist
    end

    context 'when HTML format' do
      render_views

      it 'redirects to app view' do
        create_app
        expect(response).to redirect_to(app_path('testapp'))
      end

      it 'contains a success message' do
        create_app
        expect(flash[:notice]).to include('App has been created')
      end

      it 're-renders the form again on errors' do
        create_app(name: nil)
        expect(response.body).to include('Create an app')
      end

      it 'contains an error message for invalid apps' do
        create_app(name: nil)
        expect(response.body).to include('Name is invalid')
      end
    end

    context 'when JSON format' do
      def create_app(attributes = {})
        post :create, params: { app: app.merge(attributes) }, as: :json
      end

      it 'returns success status' do
        create_app
        expect(response.status).to eq(200)
      end

      it 'returns the app as JSON' do
        create_app
        expect(JSON.parse(response.body)['app']['name']).to eq('testapp')
      end

      it 'returns bad request status for invalid apps' do
        create_app(name: nil)
        expect(response.status).to eq(400)
      end

      it 'returns the error for invalid apps' do
        create_app(name: nil)
        expect(JSON.parse(response.body)['error']['name']).to eq(["can't be blank", 'is invalid'])
      end
    end
  end

  describe '#edit' do
    render_views

    def edit_app(graylog_stream = nil)
      streamed = App.create!(app)
      streamed.graylog_stream = graylog_stream
      streamed.save!
      get :edit, params: { id: 'testapp' }
    end

    it 'renders the edit template' do
      edit_app
      expect(response.body).to include("<a class='active nav-link' href='/apps/testapp/edit'>Edit settings</a>")
    end

    it 'displays app details' do
      edit_app
      expect(response.body).to include('testapp')
    end

    it 'does not show Graylog UI elements' do
      edit_app
      expect(response.body).to_not include('app_with_stream')
    end

    it 'shows Graylog UI elements if enabled' do
      enable_graylog
      edit_app
      expect(response.body).to include('app_with_stream')
    end

    it 'throws a 404 if app not found' do
      expect { get :edit, params: { id: 'inexistent' } }.to raise_error(
        ActiveRecord::RecordNotFound
      )
    end

    context 'when app has a stream' do
      before do
        enable_graylog
        edit_app(graylog_stream)
      end

      it 'ticks and disables Graylog checkbox' do
        graylog_checkbox = '<input class="form-check-input" disabled="disabled" type="checkbox" value="1" checked="checked" name="app[with_stream]" id="app_with_stream" />'
        expect(response.body).to include(graylog_checkbox)
      end
    end

    context 'when app has no stream' do
      before do
        enable_graylog
        edit_app
      end

      it 'does not tick or disable Graylog checkbox' do
        graylog_checkbox = '<input class="form-check-input" type="checkbox" value="1" name="app[with_stream]" id="app_with_stream" />'
        expect(response.body).to include(graylog_checkbox)
      end
    end
  end

  describe '#update' do
    let(:existing) { App.create!(app) }

    def add_stream
      existing.graylog_stream = graylog_stream
      existing.save!
    end

    def update_app(attributes = {})
      patch :update, params: { id: existing.name, app: app.except(:name).merge(attributes) }
    end

    it 'updates an existing app' do
      update_app(id: existing.id, description: 'updated description')
      expect(existing.reload.description).to eq('updated description')
    end

    it 'updates an existing app to create stream' do
      enable_graylog
      stub_stream_creation
      update_app(id: existing.id, with_stream: '1')
      expect(existing.reload.graylog_stream).to_not be_nil
    end

    it 'updates an existing app and its stream' do
      enable_graylog
      add_stream
      stub_stream_update(repository_name: 'updated', index_set_id: '42')
      update_app(id: existing.id, with_stream: '1', repository_name: 'updated')
      expect(existing.reload.graylog_stream.index_set_id).to eq('42')
    end

    it 'does not update an app with app validation errors' do
      update_app(id: existing.id, repository_name: nil)
      expect(existing.reload.repository_name).to_not be_nil
    end

    it 'updates an app with stream validation errors' do
      enable_graylog
      add_stream
      stub_stream_update_failure
      update_app(id: existing.id, with_stream: '1', repository_name: 'updated')
      expect(existing.reload.repository_name).to eq('updated')
    end

    it 'throws a 404 if app not found' do
      expect { patch :update, params: { id: 'inexistent' } }.to raise_error(
        ActiveRecord::RecordNotFound
      )
    end

    context 'when HTML format' do
      render_views

      it 'redirects to app overview' do
        update_app(id: existing.id)
        expect(response).to redirect_to(app_path('testapp'))
      end

      it 'contains a success message' do
        update_app(id: existing.id, title: 'new title')
        expect(flash[:notice]).to include('App has been updated.')
      end

      it 're-renders the form again on errors' do
        update_app(id: existing.id, repository_name: nil)
        expect(response.body).to include("<a class='active nav-link' href='/apps/testapp/edit'>Edit settings</a>")
      end

      it 'contains an error message for invalid apps' do
        update_app(id: existing.id, repository_name: nil)
        expect(response.body).to include('Repository name')
      end
    end

    context 'when JSON format' do
      def update_app(attributes = {})
        patch :update, params: { id: existing.name, app: app.except(:name).merge(attributes) }, as: :json
      end

      it 'returns success status' do
        update_app
        expect(response.status).to eq(200)
      end

      it 'returns the app as JSON' do
        update_app
        expect(JSON.parse(response.body)['app']['name']).to eq('testapp')
      end

      it 'returns bad request status for invalid apps' do
        update_app(name: nil)
        expect(response.status).to eq(400)
      end

      it 'returns the error for invalid apps' do
        update_app(name: nil)
        expect(JSON.parse(response.body)['error']).to include('could not be updated')
      end
    end
  end

  describe '#destroy' do
    let(:existing) { App.create!(app) }

    def add_stream
      existing.graylog_stream = graylog_stream
      existing.save!
    end

    def delete_app
      stub_nomad_job_deletion
      stub_stream_deletion
      delete :destroy, params: { id: existing.name }
    end

    it 'deletes an existing app' do
      delete_app
      expect(App).to_not exist
    end

    it 'deletes an existing app with a Graylog stream' do
      enable_graylog
      add_stream
      delete_app
      expect(App).to_not exist
    end

    it 'deletes associated Graylog stream' do
      enable_graylog
      add_stream
      delete_app
      expect(GraylogStream).to_not exist
    end

    it 'does not delete an app on error' do
      stub_nomad_job_deletion_failure
      delete :destroy, params: { id: existing.name }
      expect(App).to exist
    end

    it 'deletes an app on stream deletion error' do
      enable_graylog
      add_stream
      stub_nomad_job_deletion
      stub_stream_deletion_failure
      delete :destroy, params: { id: existing.name }
      expect(App).to_not exist
    end

    it 'throws a 404 if app not found' do
      expect { delete :destroy, params: { id: 'inexistent' } }.to raise_error(
        ActiveRecord::RecordNotFound
      )
    end

    context 'when HTML format' do
      render_views

      it 'redirects to index' do
        delete_app
        expect(response).to redirect_to(apps_path)
      end

      it 'contains a success message' do
        delete_app
        expect(flash[:notice]).to include('App has been removed')
      end

      it 'renders index on errors' do
        stub_nomad_job_deletion_failure
        delete :destroy, params: { id: existing.name }
        expect(response.body).to include('appscontent')
      end

      it 'contains an error message on errors' do
        stub_nomad_job_deletion_failure
        delete :destroy, params: { id: existing.name }
        expect(response.body).to include('Could not delete app')
      end
    end

    context 'when JSON format' do
      def delete_app
        stub_nomad_job_deletion
        stub_stream_deletion
        delete :destroy, params: { id: existing.name }, as: :json
      end

      it 'returns success status' do
        delete_app
        expect(response.status).to eq(200)
      end

      it 'returns the app as JSON' do
        delete_app
        expect(JSON.parse(response.body)['app']['name']).to eq('testapp')
      end

      it 'returns bad request status on error' do
        stub_nomad_job_deletion_failure
        delete :destroy, params: { id: existing.name }, as: :json
        expect(response.status).to eq(400)
      end

      it 'returns the error' do
        stub_nomad_job_deletion_failure
        delete :destroy, params: { id: existing.name }, as: :json
        expect(JSON.parse(response.body)['error']).to include('could not be deleted')
      end
    end
  end

  def enable_graylog
    stub_const('ENV', ENV.to_hash.merge('GRAYLOG_ENABLED' => 'true'))
  end

  def graylog_stream
    GraylogStream.new(id: 1, name: 'testapp', rule_value: 'testapp', index_set_id: 2)
  end

  def stub_stream_creation
    stub_index
    stub_start
    stub_role
  end

  def stub_stream_creation_failure
    stub_request(:get, "#{ENV['GRAYLOG_API_URI']}#{GraylogAPI::IndexSet::ENDPOINT}").to_timeout
    stub_request(:post, "#{ENV['GRAYLOG_API_URI']}#{GraylogAPI::Stream::ENDPOINT}").to_timeout
  end

  def stub_stream_update(repository_name: 'rocksteady', index_set_id: '2')
    stub_index(repository_name: repository_name, index_set_id: index_set_id)
    body = { id: '1', index_set_id: index_set_id }
    stub_request(:put, "#{ENV['GRAYLOG_API_URI']}#{GraylogAPI::Stream::ENDPOINT}/1").to_return(
      status: 200, body: body.to_json, headers: { 'Content-Type': 'application/json' }
    )
  end

  def stub_stream_update_failure
    stub_request(:get, "#{ENV['GRAYLOG_API_URI']}#{GraylogAPI::IndexSet::ENDPOINT}").to_timeout
    stub_request(:put, "#{ENV['GRAYLOG_API_URI']}#{GraylogAPI::Stream::ENDPOINT}/1").to_timeout
  end

  def stub_stream_deletion
    stub_index
    stream_url = "#{ENV['GRAYLOG_API_URI']}#{GraylogAPI::Stream::ENDPOINT}"
    stub_request(:delete, "#{stream_url}/1").to_return(
      status: 200, body: { id: '1' }.to_json, headers: { 'Content-Type': 'application/json' }
    )
  end

  def stub_stream_deletion_failure
    stub_index
    stub_request(:delete, "#{ENV['GRAYLOG_API_URI']}#{GraylogAPI::Stream::ENDPOINT}/1").to_timeout
  end

  def stub_nomad_job_deletion
    app_url = "#{ENV['NOMAD_API_URI']}/v1/job/testapp"
    stub_request(:delete, app_url).to_return(
      status: 200, body: { EvalID: '42' }.to_json, headers: { 'Content-Type': 'application/json' }
    )
  end

  def stub_nomad_job_deletion_failure
    stub_request(:delete, "#{ENV['NOMAD_API_URI']}/v1/job/testapp").to_return(
      status: 404, body: { EvalID: '42' }.to_json, headers: { 'Content-Type': 'application/json' }
    )
  end

  def stub_index(repository_name: 'rocksteady', index_set_id: '2')
    body = { index_sets: [{ 'id' => index_set_id, 'index_prefix' => repository_name }] }
    stub_request(:get, "#{ENV['GRAYLOG_API_URI']}#{GraylogAPI::IndexSet::ENDPOINT}").to_return(
      status: 200, body: body.to_json, headers: { 'Content-Type': 'application/json' }
    )
  end

  def stub_start
    stream_url = "#{ENV['GRAYLOG_API_URI']}#{GraylogAPI::Stream::ENDPOINT}"
    stub_request(:post, stream_url).to_return(
      status: 201, body: { stream_id: '1' }.to_json, headers: { 'Content-Type': 'application/json' }
    )
    stub_request(:post, "#{stream_url}/1#{GraylogAPI::Stream::START_PATH}").to_return(
      status: 204, body: ''
    )
  end

  def stub_role
    role_url = "#{ENV['GRAYLOG_API_URI']}#{GraylogAPI::Role::ENDPOINT}/Dev"
    dev_role = {
      name: 'Dev', description: 'Altmetric developers', permissions: ['streams:read:321'], read_only: false
    }
    stub_request(:get, role_url).to_return(
      status: 200, body: dev_role.to_json, headers: { 'Content-Type': 'application/json' }
    )
    dev_role[:permissions] = ['streams:read:321', 'streams:read:1']
    stub_request(:put, role_url).to_return(
      status: 200, body: dev_role.to_json, headers: { 'Content-Type': 'application/json' }
    )
  end
end

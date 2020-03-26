DOCKER_TAG = /\w[\w.-]{,127}/.freeze

Rails.application.routes.draw do
  root to: redirect('/apps')

  resources :apps do
    member do
      get 'job_spec'
      get 'nomad'
      get 'details'
    end
  end

  namespace :api, format: :json do
    get 'app/:id/status' => 'app#status', :as => :app_status
    get 'app/:id/nomad_status' => 'app#nomad_status', :as => :app_nomad_status
    get 'app/:id/images' => 'app#images', :as => :app_images
    post 'app/:id/deploy/(:tag)' => 'app#deploy', :as => :app_deploy, :tag => DOCKER_TAG
  end

  post '/webhook' => 'webhook#deploy'
  post '/webhook/:app' => 'webhook#deploy_app'

  get '/ping' => proc { [200, {}, ['']] }
end

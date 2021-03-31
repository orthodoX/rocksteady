class AppsController < ApplicationController
  before_action :set_app, except: %i[new create index]

  def set_app
    @app = App.find_by!(name: params[:id])
  end

  def index
    respond_to do |format|
      format.html do
        @repos = AppIndex.new.repos_html
      end

      format.json do
        render status: :ok, json: AppIndex.new.repos_json
      end
    end
  end

  def show
    render :deploy
  end

  def job_spec; end

  def details; end

  def nomad; end

  def new
    @app = App.new
  end

  def create
    @app = AppCreation.new(app_params: app_params, add_stream: add_stream?).create
    result = @app.save

    respond_to do |format|
      format.html do
        if result
          flash[:notice] = 'App has been created'
          redirect_to app_path(@app)
        else
          render action: :new
        end
      end

      format.json do
        if result
          render status: :ok, json: { app: @app }
        else
          render status: :bad_request, json: { error: @app.errors }
        end
      end
    end
  end

  def edit; end

  def update
    result = AppUpdate.new(@app, add_stream: add_stream?, update_stream: update_stream?).update(app_params)

    respond_to do |format|
      format.html do
        if result[:updated]
          flash[:notice] = 'App has been updated. You will need to deploy again for any changes to take effect.'
          flash[:warning] = result[:warning] if result[:warning]
          redirect_to app_path(@app)
        else
          render action: :edit
        end
      end

      format.json do
        if result[:updated]
          render status: :ok, json: result[:warning] ? { warning: result[:warning], app: @app } : { app: @app }
        else
          render status: :bad_request, json: { error: "Error: #{@app.name} could not be updated" }
        end
      end
    end
  end

  def destroy
    result = AppDeletion.new(@app).delete!

    respond_to do |format|
      format.html do
        if result[:deleted] && @app&.destroy
          flash[:notice] = 'App has been removed from Nomad and deleted'
          flash[:warning] = result[:warning] if result[:warning]
          redirect_to action: :index
        else
          flash[:error] = 'Could not delete app'
          @repos = AppIndex.new.repos_html
          render action: :index
        end
      end

      format.json do
        if result[:deleted] && @app&.destroy
          render status: :ok, json: result[:warning] ? { warning: result[:warning], app: 'App deleted' } : { app: 'App deleted' }
        else
          render status: :bad_request, json: { error: 'Error: App could not be deleted' }
        end
      end
    end
  end

  private

  def app_params
    params.require(:app).permit(
      :name,
      :description,
      :image_source,
      :repository_name,
      :job_spec,
      :auto_deploy,
      :auto_deploy_branch
    )
  end

  def graylog_params
    params.require(:app).permit(
      :add_graylog_stream,
      :update_graylog_stream
    )
  end

  def add_stream?
    graylog_params[:add_graylog_stream] == '1'
  end

  def update_stream?
    graylog_params[:update_graylog_stream] == '1'
  end
end

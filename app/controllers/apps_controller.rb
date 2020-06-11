class AppsController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        @repos = App.all.group_by(&:repository_name).sort_by { |repo_name, _| repo_name }
      end
      format.json do
        render status: :ok, json: App.all
      end
    end
  end

  def show
    @app = current_app
    render :deploy
  end

  def edit
    @app = current_app
  end

  def job_spec
    @app = current_app
  end

  def details
    @app = current_app
    render :details
  end

  def nomad
    @app = current_app
  end

  def new
    @app = App.new
  end

  def create
    @app = AppCreation.new(app_params: app_params, add_stream: add_stream?).create

    respond_to do |format|
      format.html do
        if @app.save
          flash[:notice] = 'App has been created'
          redirect_to app_path(@app)
        else
          render action: :new
        end
      end
      format.json do
        if @app.save
          render status: :ok, json: @app
        else
          render status: :bad_request, json: @app.errors
        end
      end
    end
  end

  def update
    @app = current_app
    output = AppUpdate.new(@app, add_stream: add_stream?, update_stream: update_stream?).update(app_params)

    respond_to do |format|
      format.html do
        if output[:updated]
          flash[:notice] = 'App has been updated. You will need to deploy again for any changes to take effect.'
          flash[:warning] = output[:warning] if output[:warning]
          redirect_to app_path(@app)
        else
          render action: :edit
        end
      end
      format.json do
        if output[:updated]
          render status: :ok, json: output[:warning]? { warning: output[:warning], app: @app } : @app
        else
          render status: :bad_request, json: "Warning: #{@app.name} could not be updated"
        end
      end
    end
  end

  def destroy
    @app = current_app
    output = AppDeletion.new(@app).delete!

    respond_to do |format|
      format.html do
        if output[:deleted] && @app&.destroy
          flash[:notice] = 'App has been removed from Nomad and deleted'
          flash[:warning] =  output[:warning] if output[:warning]
          redirect_to action: :index
        else
          flash[:error] = 'Could not delete app'
          render action: :index
        end
      end
      format.json do
        if output[:deleted] && @app&.destroy
          render status: :ok, json: output[:warning] ? { warning: output[:warning], app: 'App deleted' } : 'App Deleted'
        else
          render status: :bad_request, json: "Warning: App could not be deleted"
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

  def current_app
    App.find_by(name: params[:id])
  end

  def add_stream?
    graylog_params[:add_graylog_stream] == '1'
  end

  def update_stream?
    graylog_params[:update_graylog_stream] == '1'
  end
end

module Api
  class AppController < BaseController
    def status
      render json: AppStatus.new(app)
    end

    def nomad_status
      render json: AppDetailedStatus.new(app)
    end

    def images
      render json: AppImageList.new(app)
    end

    def deploy
      render json: AppDeployment.new(app, image_tag).deploy!
    end

    private

    def app
      App.find_by(name: params[:id])
    end

    def image_tag
      params[:tag]
    end
  end
end

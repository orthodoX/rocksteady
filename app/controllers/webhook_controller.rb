class WebhookController < ActionController::API
  def handle
    if app && should_deploy?
      deploy
      head 200
    elsif app
      head 204
    else
      head 404
    end
  end

  private

  def should_deploy?
    app.auto_deploy? &&
    app.auto_deploy_branch == notification.branch &&
    notification.finished? &&
    notification.success?
  end

  def app
    @app ||= App.find_by(name: params[:app])
  end

  def notification
    @notification ||= CircleBuildNotification.new(params[:payload])
  end

  def image_tag
    "build-#{notification.build_number}"
  end

  def deploy
    AppDeployment.new(app, image_tag).deploy!
  end
end

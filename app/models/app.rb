class App < ApplicationRecord
  NAME_FORMAT = /\A[a-z0-9\-]+\Z/

  validates :name, uniqueness: true, presence: true, format: { with: NAME_FORMAT }
  validates :image_source, inclusion: { in: %w[dockerhub ecr] }
  validates :repository_name, presence: true
  validates :job_spec, presence: true

  def to_param
    name
  end

  def trigger_auto_deploy(notification)
    return unless auto_deploy? &&
      auto_deploy_branch == notification.branch &&
      notification.finished? &&
      notification.success?

    AppDeployment.new(self, "build-#{notification.build_number}").deploy!
  end
end

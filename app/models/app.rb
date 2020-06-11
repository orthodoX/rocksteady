class App < ApplicationRecord
  has_one :graylog_stream, dependent: :destroy

  NAME_FORMAT = /\A[a-z0-9\-]+\Z/.freeze

  attr_accessor :validate_stream

  validates :name, uniqueness: true, presence: true, format: { with: NAME_FORMAT }
  validates :image_source, inclusion: { in: %w[dockerhub ecr] }
  validates :repository_name, presence: true
  validates :job_spec, presence: true
  validates_with GraylogValidator, if: :validate_stream

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

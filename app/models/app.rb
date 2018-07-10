class App < ApplicationRecord
  NAME_FORMAT = /\A[a-z0-9\-]+\Z/

  validates :name, uniqueness: true, presence: true, format: { with: NAME_FORMAT }
  validates :image_source, inclusion: { in: %w[dockerhub ecr] }
  validates :ecr_repository, presence: true
  validates :job_spec, presence: true
  validate :check_job_spec_is_json

  def to_param
    name
  end

  private

  def check_job_spec_is_json
    JSON.parse(job_spec || '')
  rescue JSON::ParserError
    errors.add(:job_spec, 'must be a valid JSON job spec')
  end
end

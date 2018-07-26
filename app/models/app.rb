class App < ApplicationRecord
  NAME_FORMAT = /\A[a-z0-9\-]+\Z/

  validates :name, uniqueness: true, presence: true, format: { with: NAME_FORMAT }
  validates :image_source, inclusion: { in: %w[dockerhub ecr] }
  validates :repository_name, presence: true
  validates :job_spec, presence: true
  validate :check_job_spec_is_hcl

  def to_param
    name
  end

  private

  def check_job_spec_is_hcl
    return if HCL::Checker.valid? job_spec
    errors.add(:job_spec, 'must be a valid HCL job spec')
  end
end

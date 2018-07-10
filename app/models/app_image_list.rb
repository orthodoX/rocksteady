class AppImageList
  attr_reader :app
  private :app

  def initialize(app)
    @app = app
  end

  def as_json(*)
    ecr_images.map(&method(:image_data)).sort_by { |i| i[:pushed_at] }.reverse
  end

  private

  def image_data(image)
    {
      digest: image.image_digest,
      tags: image.image_tags || [],
      size: image.image_size_in_bytes,
      pushed_at: image.image_pushed_at
    }
  end

  def ecr_client
    @ecr_client ||= Aws::ECR::Client.new(profile: ENV['AWS_PROFILE'])
  end

  # TODO: should we consider pagination? This will return a maximum of 100
  # images. Maybe we don't care?
  def ecr_images
    ecr_client.describe_images(repository_name: app.repository_name).image_details
  rescue Aws::ECR::Errors::RepositoryNotFoundException
    []
  end
end

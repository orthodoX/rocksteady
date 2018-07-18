class AppImageList
  attr_reader :app
  private :app

  ARCH = 'amd64'.freeze
  OS = 'linux'.freeze

  def initialize(app)
    @app = app
  end

  def as_json(*)
    case app.image_source
    when 'ecr'
      ecr_image_list
    when 'dockerhub'
      dockerhub_image_list
    else
      []
    end
  end

  private

  def ecr_image_list
    ecr_images.map(&method(:ecr_image_data)).sort_by { |i| i[:timestamp] }.reverse
  end

  def dockerhub_image_list
    dockerhub_tags.map(&method(:dockerhub_tag_to_image)).compact.sort_by { |i| i[:timestamp] }.reverse
  end

  def ecr_image_data(image)
    {
      id: image.image_digest,
      tags: image.image_tags || [],
      size: image.image_size_in_bytes,
      timestamp: image.image_pushed_at
    }
  end

  def dockerhub_tag_to_image(tag)
    image = tag['images'].find { |i| i['architecture'] == ARCH && i['os'] == OS }
    return unless image

    {
      id: tag['id'],
      tags: [tag['name']],
      size: image['size'],
      timestamp: Time.parse(tag['last_updated'])
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

  # TODO: also consider paginating this
  def dockerhub_tags
    HTTP.get(dockerhub_url).parse['results']
  end

  def dockerhub_url
    "https://hub.docker.com/v2/repositories/#{app.repository_name}/tags/"
  end
end

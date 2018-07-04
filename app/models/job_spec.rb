class JobSpec
  attr_reader :app, :docker_image_uri
  private :app, :docker_image_uri

  def initialize(app, docker_image_uri)
    @app = app
    @docker_image_uri = docker_image_uri
  end

  def as_json(*)
    base = app_spec

    base[:ID] = app.name
    base[:TaskGroups].each do |task_group|
      task_group[:Tasks].each do |task|
        task[:Config][:image] = docker_image_uri
      end
    end

    base
  end

  def app_spec
    @app_spec ||= JSON.parse(app.job_spec, symbolize_names: true)
  end
end

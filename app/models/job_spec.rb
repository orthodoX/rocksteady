class JobSpec
  attr_reader :app, :docker_image_name
  private :app, :docker_image_name

  def initialize(app, docker_image_name)
    @app = app
    @docker_image_name = docker_image_name
  end

  def as_json(*)
    base = json_spec

    base[:ID] = app.name
    base[:TaskGroups].each do |task_group|
      task_group[:Tasks].each do |task|
        task[:Config][:image] = docker_image_name if task[:Config][:image].blank?
      end
    end

    base
  end

  def json_spec
    @json_spec = HclParser.new(app.job_spec).parsed
  end
end

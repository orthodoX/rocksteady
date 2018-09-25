class CircleBuildNotification
  attr_reader :params
  private :params

  def initialize(params)
    @params = params
  end

  def success?
    params[:outcome] == 'success'
  end

  def finished?
    params[:lifecycle] == 'finished'
  end

  def build_number
    params[:build_num]
  end

  def branch
    params[:branch]
  end
end

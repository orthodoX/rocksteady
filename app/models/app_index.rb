class AppIndex
  def repos_html
    App.all.group_by(&:repository_name).sort_by { |repo_name, _| repo_name }
  end

  def repos_json
    App.all
  end
end

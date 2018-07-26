module JobSpecHelper
  def format_job_spec(spec)
    Rouge::Formatters::HTML.new.format(
      Rouge::Lexers::Hcl.new.lex(spec)
    ).html_safe
  end
end

module FormHelper
  def form_errors(*models)
    return if models.all? { |m| m.errors.empty? }

    errors = error_rows_from(models)

    content = content_tag(:ul, errors.uniq.join.html_safe)
    content_tag(:div, "<strong>There was a problem with your form</strong>#{content}".html_safe, class: 'form-errors alert-danger')
  end

  def error_rows_from(models)
    models.flat_map { |m|
      m.errors.full_messages.map { |error| content_tag(:li, error) }
    }
  end
end

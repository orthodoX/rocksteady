module FormHelper
  def form_errors(*models)
    return if models.all? { |m| m.errors.empty? }

    errors = error_rows_from(models)

    content_tag(:div,
                content_tag(:strong, 'There was a problem with your form') +
                content_tag(:ul, safe_join(errors.uniq)),
                class: 'form-errors alert-danger')
  end

  def error_rows_from(models)
    models.flat_map { |m|
      m.errors.full_messages.map { |error| content_tag(:li, error) }
    }
  end
end

class GraylogValidator < ActiveModel::Validator
  def validate(record)
    record.errors.add(:base, 'Could not create Graylog stream') if record.graylog_stream.blank?
  end
end

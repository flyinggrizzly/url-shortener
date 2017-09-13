# Validates URLs
class UrlValidator < ActiveModel::EachValidator
  require 'addressable'

  def validate_each(record, attribute, value)
    return if validate_url(value)
    record.errors.add(attribute, (options[:message] || :url_format))
  end

  private

  def validate_url(value)
    return false if value.blank?
    url = Addressable::URI.heuristic_parse(value)
    # host = url.host
    return false if url.host.nil?
    return url.host.match(/^(([a-z0-9][a-z0-9\-]+\.)+)?([a-z0-9][a-z0-9\-]+\.[a-z]{2,})$/i)
  rescue URI::InvalidURIError
    false
  end
end

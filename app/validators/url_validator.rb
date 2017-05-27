# Validates URLs
class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if validate_url(value)
    record.errors.add(attribute, (options[:message] || :url_format))
  end

  private

  def validate_url(value)
    url = URI.parse(value)
    return true if url.scheme.nil?
    url.scheme.in?(%w[http https])
  rescue URI::InvalidURIError
    false
  end
end

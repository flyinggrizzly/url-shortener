# Validates Short URL Slugs
class SlugValidator < ActiveModel::EachValidator

  def validate_each(record, attribute, value)
    return if validate_slug(value)
    record.errors.add(attribute, (options[:message] || :slug_format))
  end

  private

  def validate_slug(value)
    if UrlShortener::Application.config.reserved_slugs.include? value
      return false
    elsif value.match(/^([a-z0-9]+[-_]?+[a-z0-9]+)*$/i) # ensure all slugs include only a-z, 0-9, and - or _
      return true
    else
      return false
    end
  rescue StandardError
    false
  end
end

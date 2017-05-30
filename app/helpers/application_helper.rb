module ApplicationHelper
  def full_title(page_title = '')
    base_title = UrlGrey::Application.config.application_name
    if page_title.empty?
      base_title
    else
      base_title + ' | ' + page_title
    end
  end

  # Replacement for root_url method, for apps that use the root as a redirect
  def root_or_admin_url
    if UrlGrey::Application.config.root_redirect_enabled
      admin_url
    else
      root_url
    end
  end

  # Replacement for root_path method, for apps that use the root as a redirect
  def root_or_admin_path
    if UrlGrey::Application.config.root_redirect_enabled
      admin_path
    else
      root_path
    end
  end

  # Returns true if application has root redirection enabled
  def root_redirect_enabled?
    UrlGrey::Application.config.root_redirect_enabled
  end

  # Returns the redirect of the special short URL 'root', or false if it is not defined
  def root_redirect_url
    if root_short_url = ShortUrl.find_by(slug: 'root')
      root_short_url.redirect
    else
      false
    end
  end
end

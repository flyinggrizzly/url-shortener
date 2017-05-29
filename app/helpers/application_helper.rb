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
end

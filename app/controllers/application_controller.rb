class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper    # get access to the sessions helpers in all controllers
  include ApplicationHelper # force this to load earlier, mostly for tests

  def hello
    render html: "'Sup y'all?"
  end

  def root
    if root_redirect_enabled? && root_redirect_url
      redirect_to root_redirect_url
    else
      render 'static_pages/home'
    end
  end
end

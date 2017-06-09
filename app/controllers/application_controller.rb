class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include ApplicationHelper # force this to load earlier, mostly for tests
  include SessionsHelper    # get access to the sessions helpers in all controllers

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

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include ApplicationHelper  # force this to load earlier, mostly for tests
  include SessionsHelper     # get access to the sessions helpers in all controllers
  include ShortUrlHitsHelper # get access to the record_hit method

  before_action :set_paper_trail_whodunnit

  def root
    if root_redirect_enabled? && root_redirect_url
      # Explicitly pass the slug used because
      # this bypasses the standard requests controller
      redirect_to root_redirect_url

      # Record usage *after* redirecting so users don't wait
      record_hit('root')
    else
      render 'static_pages/home'
    end
  end
end

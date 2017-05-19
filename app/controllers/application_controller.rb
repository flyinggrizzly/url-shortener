class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def hello
    render html: "'Sup y'all?"
  end
end

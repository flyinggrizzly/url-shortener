class ShortUrlRequestsController < ApplicationController

  def show
    if @short_url = ShortUrl.find_by(slug: params[:slug].downcase)
      send_to_redirect

      # Record usage *after* redirecting so users don't wait
      record_hit
      # log use of short url
    else
      flash[:warn] = 'The short URL you requested does not exist.'
      redirect_to root_or_admin_url
    end
  end

  private

  # Sends the user to the requested redirect
  def send_to_redirect
    redirect_to @short_url.redirect
  end
end

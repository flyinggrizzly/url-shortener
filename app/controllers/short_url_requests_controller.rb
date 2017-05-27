class ShortUrlRequestsController < ApplicationController

  def show
    if @short_url = ShortUrl.find_by(slug: params[:slug])
      redirect_to @short_url.redirect
      # log use of short url
    else
      flash[:warn] = 'The short URL you requested does not exist.'
      redirect_to root_url
    end
  end
end

class ShortUrlsController < ApplicationController
  def index
    @short_urls = ShortUrl.all
  end

  def show
    @short_url = ShortUrl.find(params[:id])
  end

  def new
    @short_url = ShortUrl.new
  end

  def create
  end
end

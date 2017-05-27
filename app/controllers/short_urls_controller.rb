class ShortUrlsController < ApplicationController
  def index
    @short_urls = ShortUrl.paginate(page: params[:page])
  end

  def show
    @short_url = ShortUrl.find(params[:id])
  end

  def new
    @short_url = ShortUrl.new
  end

  def create
    @short_url = ShortUrl.new(short_url_params)
    if @short_url.save
      flash[:success] = "#{@short_url.url_alias} was created successfully."
      redirect_to short_urls_path
    else
      render 'new'
    end
  end

  def edit
    @short_url = ShortUrl.find(params[:id])
  end

  def update
    @short_url = ShortUrl.find(params[:id])
    if @short_url.update_attributes(short_url_params)
      flash[:success] = "#{@short_url.url_alias} updated successfully."
      redirect_to short_urls_path
    else
      render 'edit'
    end
  end

  private

  def short_url_params
    params.require(:short_url).permit(:url_alias, :redirect)
  end

  ###### Filters ######################################################################################################
end

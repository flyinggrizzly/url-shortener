class ShortUrlsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

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

  def delete
    @short_url = ShortUrl.find(params[:id])
  end

  def destroy
    ShortUrl.find(params[:id]).destroy
    flash[:success] = 'Short URL deleted.'
    redirect_to short_urls_path
  end

  private

  def short_url_params
    params.require(:short_url).permit(:url_alias, :redirect)
  end

  ###### Filters ############################

  def logged_in_user
    unless logged_in?
      store_destination_url
      flash[:danger] = 'Please log in.'
      redirect_to login_url
    end
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end
end

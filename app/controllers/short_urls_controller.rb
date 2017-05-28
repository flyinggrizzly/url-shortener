class ShortUrlsController < ApplicationController
  before_action :logged_in_user, except: [:search]
  before_action :admin_user,     except: [:search]

  def index
    @short_urls = ShortUrl.paginate(page: params[:page])
  end

  def search
    search_by_type(params)
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
      flash[:success] = "#{@short_url.slug} was created successfully."
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
      flash[:success] = "#{@short_url.slug} updated successfully."
      redirect_to short_urls_path
    else
      render 'edit'
    end
  end

  def delete
    @short_url = ShortUrl.find(params[:id])
  end

  def destroy
    @short_url = ShortUrl.find(params[:id])
    @short_url.destroy
    flash[:success] = "Short URL '#{@short_url.slug} has been deleted."
    redirect_to short_urls_path
  end

  private

  # Strengthens parameters
  def short_url_params
    params.require(:short_url).permit(:slug, :redirect)
  end

  # Performs search or reverse search based on request
  def search_by_type(params)
    if params[:search]
      @short_urls = ShortUrl.search(params[:search]).order('slug ASC')
    elsif params[:reverse_search]
      @short_urls = ShortUrl.reverse_search(params[:reverse_search]).order('slug ASC')
    end
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

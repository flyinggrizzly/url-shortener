class ShortUrlsController < ApplicationController
  before_action :logged_in_user, except: [:search]
  before_action :admin_user,     only:   [:edit,
                                          :update,
                                          :delete,
                                          :destroy,
                                          :many_new]

  def index
    @short_urls = ShortUrl.paginate(page: params[:page])
  end

  def search
    search_by_type(params)
  end

  def show
    if @short_url = ShortUrl.find_by(slug: params[:slug])
      @short_url
    else
      flash[:warn] = 'That short URL does not exist.'
      redirect_to root_or_admin_url
    end
  end

  def new
    @short_url = ShortUrl.new
  end

  # Renders form to upload many new short URLs
  def batch_new; end

  def create
    @short_url = ShortUrl.new(short_url_params)
    if @short_url.save
      flash[:success] = "#{@short_url.slug} was created successfully."
      redirect_to short_urls_path
    else
      render 'new'
    end
  end

  # Create and update short URLs in a batch
  def batch_create_and_update
    short_urls = read_batch_csv
    urls_to_update, urls_to_create = identify_action_for_record(short_urls)
    
    urls_to_create.each { |url| ShortUrl.create!(slug: url[0], redirect: url[1]) }

    urls_to_update.each do |url|
      short_url = ShortUrl.find_by(slug: url[0])
      short_url.update_attribute(redirect: url[1])
    end

    # TODO: how the frack do I capture and render the records that didn't pass validation? Check RailsCast 165
  end

  def edit
    @short_url = ShortUrl.find_by(slug: params[:slug])
  end

  def update
    @short_url = ShortUrl.find_by(slug: params[:slug])
    if @short_url.update_attributes(short_url_params)
      flash[:success] = "#{@short_url.slug} updated successfully."
      redirect_to short_urls_path
    else
      render 'edit'
    end
  end

  def delete
    @short_url = ShortUrl.find_by(slug: params[:slug])
  end

  def destroy
    @short_url = ShortUrl.find_by(slug: params[:slug])
    @short_url.destroy
    flash[:success] = "Short URL '#{@short_url.slug}' has been deleted."
    redirect_to short_urls_path
  end

  private

  # Strengthens parameters
  def short_url_params
    if ShortUrl.find_by(slug: params[:slug]) # Only permit redirect editing if the short URL exists
      params.require(:short_url).permit(:redirect)
    else
      params.require(:short_url).permit(:slug, :random_slug, :redirect)
    end
  end

  # Returns two arrays: one of short URLs to update, one of short URLs to create
  def identify_action_for_record(short_urls)
    short_urls.each do |short_url|
      if ShortUrl.find_by(slug: short_url[0])
        updates << short_url
      else
        creates << short_url
      end
    end
    return updates, creates
  end

  # Reads and parses CSV for batch operation
  def read_batch_csv
    CSV.read(params[short_urls_csv_params])
  end

  # Accepts CSV files and sanitizes them for creating many short URLs
  def short_urls_csv_params
    params.require(:short_urls_csv).permit(:short_urls_csv)
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
    redirect_to root_or_admin_url unless current_user.admin?
  end
end

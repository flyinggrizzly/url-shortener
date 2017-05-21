class UsersController < ApplicationController
  before_action :logged_in_user
  before_action :correct_or_admin_user, only: [:show, :edit, :update]
  before_action :admin_user, only: [:new, :create, :index, :destroy, :delete]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "#{@user.name} was created successfully."
      redirect_to users_path
    else
      render 'new'
    end
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = 'User updated'
      redirect_to root_url
    else
      render 'edit'
    end
  end

  # Non-RESTtful resource. Provides a non-JS fall-back for the destroy action.
  # For source and details see RailsCast 77 revised:
  # http://railscasts.com/episodes/77-destroy-without-javascript-revised?autoplay=true
  def delete
    @user = User.find(params[:id])
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'User deleted.'
    redirect_to users_url
  end

  private

  def user_params
    if current_user.admin?
      params.require(:user).permit(:name,
                                   :email,
                                   :admin,
                                   :password,
                                   :password_confirmation)
    else
      params.require(:user).permit(:name,
                                   :email,
                                   :password,
                                   :password_confirmation)
    end
  end

  ###### Filters ######################################################################################################

  def logged_in_user
    unless logged_in?
      store_destination_url
      flash[:danger] = 'Please log in.'
      redirect_to login_url
    end
  end

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end

  def correct_or_admin_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user) || current_user.admin?
  end
end

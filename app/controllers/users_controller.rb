class UsersController < ApplicationController
  before_action :logged_in_user
  before_action :correct_or_admin_user, only: [:edit, :update]
  # before_action :admin_user, only: [:new, :create, :index, :show, :edit, :update, :destroy, :delete]

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
    @users = User.all
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

  def delete; end

  def destroy; end

  private

  def user_params
    params.require(:user).permit(:name, :email,
                                 :password,
                                 :password_confirmation)
  end

  ###### Filters ######################################################################################################

  def logged_in_user
    unless logged_in?
      store_destination_url
      flash[:danger] = 'Please log in.'
      redirect_to login_url
    end
  end

  def correct_or_admin_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
end

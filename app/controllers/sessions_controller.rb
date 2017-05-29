class SessionsController < ApplicationController
  before_action

  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_back_or root_or_admin_url
    else
      flash.now[:danger] = 'Could not log in because of an invalid password/email combination.'
      render 'new'
    end
  end

  def delete
    @user = current_user
  end

  def destroy
    log_out if logged_in?
    redirect_to root_or_admin_url
  end
end

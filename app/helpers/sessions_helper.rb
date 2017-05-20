module SessionsHelper
  # Logs in the given user
  def log_in(user)
    session[:user_id] = user.id
  end

  # Returns the currently logged in user, if any
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Returns true if a given user is logged in
  def logged_in?
    !current_user.nil?
  end

  # Logs out the current user
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # Sets cookies to remmeber the user for 10 days
  def remember(user)
    # Require semi-frequent logins for security
    expiry_date = 10.days.from_now.utc
    user.remember
    cookies.signed[:user_id] = { value:   user.id,
                                 expires: expiry_date }
    cookies[:remember_token] = { value:   user.remember_token,
                                 expires: expiry_date }
  end

  # Logs out the current user
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
end

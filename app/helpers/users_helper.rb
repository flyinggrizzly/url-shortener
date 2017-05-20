module UsersHelper
  def user_role
    if @user.admin?
      "Admin"
    else
      "User"
    end
  end
end

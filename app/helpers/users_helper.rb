module UsersHelper
  def user_role(u = nil)
    u ? user = u : user = @user
    if user.admin?
      "Admin"
    else
      "User"
    end
  end
end

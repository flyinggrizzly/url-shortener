module InteractionsHelper
  def fill_in_login_details_and_log_in_as(user)
    fill_in      'Email',    with: user.email
    fill_in      'Password', with: user.password
    click_button 'Log in'
  end
end
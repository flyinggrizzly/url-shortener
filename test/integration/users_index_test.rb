require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  
  def setup
    @admin = users(:cthulhu)
    @user  = users(:yig)
  end

  test 'index includes pagination' do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', edit_user_path(user), text: 'Edit'
    end
  end

  test 'index only available to admins' do
    log_in_as(@user)
    get users_path
    assert_redirected_to root_or_admin_url
  end
end

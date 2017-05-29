require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user  = users(:yig)
    @admin = users(:cthulhu)
  end

  test 'unsuccessful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name:                  '',
                                              email:                 'foo@invalid',
                                              password:              'foo',
                                              password_confirmation: 'bar' } }
    assert_template 'users/edit'
    assert_select 'div#error_explanation'
    assert_select 'li.error-item', count: 4
  end

  test 'successful edit' do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name  = 'Foo Bar'
    email = 'foo@bar.com'
    patch user_path(@user), params: { user: { name:                  name,
                                              email:                 email,
                                              password:              '',
                                              password_confirmation: '' } }
    assert_not flash.empty?
    assert_redirected_to root_or_admin_url
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test 'edit screen has right fields' do
    log_in_as(@admin)
    get edit_user_path(@admin)
    assert_template 'users/edit'
    assert_select 'input[name=?]', 'user[name]'
    assert_select 'input[name=?]', 'user[email]'
    assert_select 'input[name=?]', 'user[password]'
    assert_select 'input[name=?]', 'user[password_confirmation]'
    assert_select 'input[name=?]', 'user[admin]'
  end
end

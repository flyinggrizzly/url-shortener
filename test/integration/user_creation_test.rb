require 'test_helper'

class UserCreationTest < ActionDispatch::IntegrationTest

  def setup
    @admin = users(:cthulhu)
    log_in_as(@admin)

    @good_params = { name:                  'Cheryl',
                     email:                 'kristall@figgis.agency',
                     password:              'tunt4eva-cherlene-rocks',
                     password_confirmation: 'tunt4eva-cherlene-rocks' }
    @bad_params  = { name:                  ' ',
                     email:                 'foo@bar,com',
                     password:              'foobar',
                     password_confirmation: 'fooba' }
  end

  test 'invalid user info should not be accepted' do
    get new_user_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: @bad_params }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'li.error-item', count: 4
  end

  test 'valid user info is successful' do
    get new_user_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: @good_params }
    end
    assert_redirected_to users_path
    follow_redirect!
    assert_match "#{@good_params['name']} was created successfully.", response.body
  end

  test 'creation screen has right fields' do
    log_in_as(@admin)
    get new_user_path
    assert_template 'users/new'
    assert_select 'input[name=?]', 'user[name]'
    assert_select 'input[name=?]', 'user[email]'
    assert_select 'input[name=?]', 'user[password]'
    assert_select 'input[name=?]', 'user[password_confirmation]'
    assert_select 'input[name=?]', 'user[admin]'
  end
end

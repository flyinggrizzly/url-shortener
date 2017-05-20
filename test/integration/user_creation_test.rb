require 'test_helper'

class UserCreationTest < ActionDispatch::IntegrationTest

  def setup
    @good_params = { name:                  'Cheryl',
                                         email:                 'kristall@figgis.agency',
                                         password:              'tunt4eva-cherlene-rocks',
                                         password_confirmation: 'tunt4eva-cherlene-rocks' }
    @bad_params  = { name:                  ' ',
                                         email:                 'foo@bar,com',
                                         password:              'foobar',
                                         password_confirmation: 'fooba' }
  end

  test 'invalid signup info should not be accepted' do
    get new_user_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: @bad_params }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'li.error-item', count: 4
  end

  test 'valid signup info is successful' do
    get new_user_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: @good_params }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match "#{@good_params['name']} was created successfully.", response.body
  end
end

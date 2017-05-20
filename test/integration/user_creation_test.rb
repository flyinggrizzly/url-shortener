require 'test_helper'

class UserCreationTest < ActionDispatch::IntegrationTest
  def setup
    user_params = {
      name:                  'Amadeus Arkham',
      email:                 'arkham@asylum.org',
      role:                  'user',
      password:              'goofballgoofball',
      password_confirmation: 'goofballgoofball'
    }
  end

  test 'form should have right fields' do
    get new_user_path
    assert_response :success
  end
end

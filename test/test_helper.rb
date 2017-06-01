require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

require "simplecov"
SimpleCov.start

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include ApplicationHelper

  # Returns true if a test user is logged in
  def is_logged_in?
    !session[:user_id].nil?
  end

  # Logs in as a given user for a test
  def log_in_as(user)
    session[:user_id] = user.id
  end
end

class ActionDispatch::IntegrationTest
  # Logs in as a given user for a test
  def log_in_as(user, password: 'goofballgoofball', remember_me: '1')
    post login_path, params: { session: { email:       user.email,
                                          password:    password,
                                          remember_me: remember_me } }
  end
end


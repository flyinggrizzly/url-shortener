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

  def log_out
    session[:user_id] = nil
  end

  # Enables PaperTrail for specific tests
  def with_versioning
    was_enabled = PaperTrail.enabled?
    was_enabled_for_controller = PaperTrail.enabled_for_controller?
    PaperTrail.enabled = true
    PaperTrail.enabled_for_controller = true
    begin
      yield
    ensure
      PaperTrail.enabled = was_enabled
      PaperTrail.enabled_for_controller = was_enabled_for_controller
    end
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


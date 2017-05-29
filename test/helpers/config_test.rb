require 'test_helper'

class ConfigTest < ActionView::TestCase

  test 'app name can be changed' do
    UrlGrey::Application.config.application_name = 'foobar'
    assert_equal 'foobar', full_title
  end
end

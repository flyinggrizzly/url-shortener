require 'test_helper'

class ShortUrlsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:cthulhu)

    @short_url = short_urls(:example)
  end

  test 'admins can get index' do
    log_in_as(@admin)
    get short_urls_path
    assert_response :success
  end

  test 'admins can get show' do
    log_in_as(@admin)
    get short_url_path(@short_url)
    assert_response :success
  end

  test 'admins can get new' do
    log_in_as(@admin)
    get new_short_url_path
    assert_response :success
  end

  test 'admins can post create' do
  end

  test 'admins can get edit' do
  end

  test 'admins can patch update' do
  end

  test 'admins can get delete' do
  end

  test 'admins can destroy' do
  end

end

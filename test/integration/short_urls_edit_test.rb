require 'test_helper'

class ShortUrlsEditTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:cthulhu)
    log_in_as(@admin)
  end
end

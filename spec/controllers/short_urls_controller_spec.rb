require 'rails_helper'
require 'support/batchable_spec'

RSpec.describe ShortUrlsController, type: :controller do

  # Test that the Batchable concern is included in the controller
  describe 'includes Batchable' do
    it { expect(ShortUrlsController.ancestors.include? Batchable).to eq(true) }
  end

  it_behaves_like 'batch controller actions' do
    let(:controller) { ShortUrlsController.new }
  end
end
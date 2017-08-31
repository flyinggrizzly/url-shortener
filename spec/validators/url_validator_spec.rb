require 'rails_helper'

class HasUrl 
  # Include AR awesomeness without require a database table
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming

  # Create virtual attribute to validate without database table
  attr_accessor :web_address
  # Validate it
  validates     :web_address, url: true
end

RSpec.describe UrlValidator do

  let(:object) { HasUrl.new }

  it 'rejects empty strings' do
    object.web_address = ''
    expect(object).not_to be_valid
  end

  it 'rejects nil' do
    object.web_address = nil
    expect(object).not_to be_valid
  end

  it 'rejects string that do not evaluate to websites' do
    object.web_address = 'foo bar'
    expect(object).not_to be_valid
  end

  context 'when passed a valid web address' do
    it 'accepts the address with a scheme' do
      object.web_address = 'https://www.flyinggrizzly.io'
      expect(object).to be_valid
    end

    it 'accepts the address without a scheme' do
      object.web_address = 'www.flyinggrizzly.io'
      expect(object).to be_valid
    end
  end

  context 'when passed a valid hostname and port' do
    it 'accepts the address with a scheme' do
      object.web_address = 'http://dev.grz.li:3000'
      expect(object).to be_valid
    end

    it 'accepts the address without a scheme' do
      object.web_address = 'dev.grz.li:3000'
      expect(object).to be_valid
    end
  end
end
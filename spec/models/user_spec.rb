require 'rails_helper'

RSpec.describe User, type: :model do
  # Helper method for user details
  def user_details(name:                  'Khelben Blackstaff',
                   email:                 'the-blackstaff@moonstars.net',
                   password:              'goofballgoofball',
                   password_confirmation: 'goofballgoofball')
    { name:                  name,
      email:                 email,
      password:              password,
      password_confirmation: password_confirmation }
  end

  it 'is valid with a name, email, password' do
    user = User.new(user_details)
    expect(user).to be_valid
  end

  it 'is invalid without name' do
    user = User.new(user_details(name: ' '))
    expect(user).not_to be_valid
  end

  it 'is invalid without an email' do
    user = User.new(user_details(email: ' '))
    expect(user).not_to be_valid
  end

  it 'is invalid without a password' do
    user = User.new(user_details(password: nil))
    expect(user).not_to be_valid
  end

  describe 'name' do
    it 'must not be blank'
    it 'must not be longer than 50 characters'
  end

  describe 'email' do
    it 'must not be blank'
    it 'must not be longer than 255 chracters'
    it 'must be a valid email address'
    it 'must be case-insensitive unique'
  end

  describe 'password' do
    it 'must be longer than 15 characters'
  end

  describe '::digest' do
    pending
  end
end

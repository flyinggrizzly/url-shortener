require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name:                  'Sterling Archer',
                     email:                 'archer@figgis.agency',
                     role:                  'user',
                     password:              'foobarfoobargoof',
                     password_confirmation: 'foobarfoobargoof')
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'name should be present' do
    @user.name = '    '
    assert_not @user.valid?
  end

  test 'name should not be too long' do
    @user.name = 'a' * 51
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = '    '
    assert_not @user.valid?
  end

  test 'email should not be too long' do
    @user.email = 'a' * 244 + '@example.com'
    assert_not @user.valid?
  end

  test 'email validation should accept valid addresses' do
    valid_addresses = %w(user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn)
    valid_addresses.each do |address|
      @user.email = address
      assert @user.valid?, "#{address.inspect} should be valid"
    end
  end

  test 'email validation should reject bad addresses' do
    invalid_addresses = %w(user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com)
    invalid_addresses.each do |addy|
      @user.email = addy
      assert_not @user.valid?, "#{addy.inspect} should not be valid"
    end
  end

  test 'email addresses should be unique' do
    dupe_user = @user.dup
    @user.save
    assert_not dupe_user.valid?

    # make sure we catch case variation on repeated email addresses
    dupe_user.email.upcase!
    assert_not dupe_user.valid?
  end

  test 'email addresses should be saved as lowercase' do
    mixed_case_email = 'Foo@ExamPlE.Com'
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test 'role should not be blank' do
    @user.role = ' '
    assert_not @user.valid?
  end

  test 'role should only be admin or user' do
    @user.role = 'secret_agent'
    assert_not @user.valid?
    @user.role = 'admin'
    assert @user.valid?
  end

  test 'role should be saved as lowercase' do
    mixed_case_role = 'ADmIn'
    @user.role = mixed_case_role
    @user.save
    assert_equal mixed_case_role.downcase, @user.reload.role
  end

  test 'password should not be blank' do
    @user.password = @user.password_confirmation = ' ' * 16
    assert_not @user.valid?
  end

  test 'password should have a minimum length' do
    @user.password = @user.password_confirmation = 'foobar'
    assert_not @user.valid?
  end
end

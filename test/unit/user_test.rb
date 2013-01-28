require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "factory_girl working" do
    user = FactoryGirl.build(:user)
    assert user.valid?
  end  
end

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid inspector by default" do
    user = User.new(email_address: "test@example.com", password: "password123", name: "Ana")
    assert user.valid?
    assert user.inspector?
    assert_not user.admin?
  end

  test "admin role" do
    user = User.new(email_address: "admin@example.com", password: "password123", name: "Admin", role: :admin)
    assert user.admin?
  end

  test "email is downcased and stripped on normalize" do
    user = User.create!(email_address: "  TEST@Example.COM  ", password: "password123", name: "X")
    assert_equal "test@example.com", user.email_address
  end
end

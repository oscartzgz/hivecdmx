require "test_helper"

class ReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @inspector = users(:inspector_one)
    @admin     = users(:admin_one)
  end

  test "inspector is redirected from reports" do
    post session_url, params: { session: { email_address: @inspector.email_address, password: "password123" } }
    get reports_url
    assert_redirected_to root_path
    assert_equal "Acceso restringido.", flash[:alert]
  end

  test "inspector is redirected from export" do
    post session_url, params: { session: { email_address: @inspector.email_address, password: "password123" } }
    get export_reports_url
    assert_redirected_to root_path
    assert_equal "Acceso restringido.", flash[:alert]
  end

  test "admin can access reports" do
    post session_url, params: { session: { email_address: @admin.email_address, password: "password123" } }
    get reports_url
    assert_response :success
  end
end

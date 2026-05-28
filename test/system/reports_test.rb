require "application_system_test_case"

class ReportsTest < ApplicationSystemTestCase
  test "inspector cannot access reports" do
    sign_in_as create_inspector
    visit reports_url
    assert_current_path root_path, wait: 5
    assert_text "Acceso restringido."
  end

  test "admin can access reports" do
    sign_in_as create_admin
    visit reports_url
    assert_text "Reporte diario"
  end
end

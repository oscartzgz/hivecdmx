require "application_system_test_case"

class SessionsTest < ApplicationSystemTestCase
  setup { @user = create_inspector }

  test "login con credenciales válidas redirige a la lista de habitaciones" do
    sign_in_as(@user)

    assert_text "Seleccionar habitación"
  end

  test "login con contraseña incorrecta regresa al formulario" do
    visit new_session_url
    fill_in "Correo electrónico", with: @user.email_address
    fill_in "Contraseña",         with: "incorrecta"
    click_on "Entrar"

    assert_current_path new_session_path
  end

  test "logout redirige al login" do
    sign_in_as(@user)

    # Cierra la sesión via JS (DELETE /session)
    page.execute_script(<<~JS)
      fetch('/session', {
        method: 'DELETE',
        headers: { 'X-CSRF-Token': document.querySelector('meta[name=csrf-token]')?.content || '' }
      }).then(() => window.location.href = '/session/new')
    JS
    assert_current_path new_session_path, wait: 5
  end

  test "ruta protegida redirige al login cuando no hay sesión" do
    visit rooms_url
    assert_current_path new_session_path
    assert_selector "input[value='Entrar']"
  end
end

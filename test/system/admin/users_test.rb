require "application_system_test_case"

module Admin
  class UsersTest < ApplicationSystemTestCase
    setup do
      @admin     = create_admin
      @inspector = create_inspector
    end

    # ── Control de acceso ───────────────────────────────────────────────────

    test "inspector no puede acceder al área de admin" do
      sign_in_as(@inspector)
      visit admin_users_url

      assert_no_current_path admin_users_path
    end

    test "admin puede acceder a la lista de usuarios" do
      sign_in_as(@admin)
      visit admin_users_url

      assert_text "Usuarios"
      assert_text @inspector.name
      assert_text @admin.name
    end

    # ── CRUD ────────────────────────────────────────────────────────────────

    test "admin crea un usuario nuevo" do
      sign_in_as(@admin)
      visit admin_users_url
      click_link "Nuevo usuario"

      fill_in "Nombre",  with: "Nuevo Inspector"
      fill_in "Correo",  with: "nuevo@hive.mx"
      fill_in "Contraseña", with: "segura123"
      click_button "Crear usuario"

      assert_current_path admin_users_path
      assert_text "Usuario creado"
      assert_text "Nuevo Inspector"
    end

    test "admin edita el nombre de un usuario" do
      sign_in_as(@admin)
      visit admin_users_url

      within find_user_row(@inspector) do
        click_link "Editar"
      end

      fill_in "Nombre", with: "Ana Actualizada"
      click_button "Guardar"

      assert_current_path admin_users_path
      assert_text "Usuario actualizado"
      assert_text "Ana Actualizada"
    end

    test "admin elimina a otro usuario" do
      sign_in_as(@admin)
      visit admin_users_url

      accept_confirm do
        within find_user_row(@inspector) do
          click_button "Eliminar"
        end
      end

      assert_current_path admin_users_path
      assert_text "Usuario eliminado"
      assert_no_text @inspector.name
    end

    test "admin no puede eliminarse a sí mismo" do
      sign_in_as(@admin)
      visit admin_users_url

      accept_confirm do
        within find_user_row(@admin) do
          click_button "Eliminar"
        end
      end

      assert_current_path admin_users_path
      assert_text "No puedes eliminarte a ti mismo"
      assert_text @admin.name
    end

    private

    # Busca la fila del usuario por su nombre en la lista de admin.
    def find_user_row(user)
      # La vista renderiza cada usuario como un div con strong (nombre) dentro.
      find("strong", text: user.name, exact_text: true).ancestor("div[style*='justify-content:space-between']")
    end
  end
end

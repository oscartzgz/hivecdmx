require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # Los tests de sistema usan un servidor Puma en un hilo separado; no podemos
  # compartir la conexión de la transacción sin riesgo de corrupción concurrente
  # (error cmd_tuples con Turbo Stream). Por eso desactivamos las transacciones
  # y creamos/destruimos los datos manualmente.
  self.use_transactional_tests = false

  # Deshabilitar la carga automática de fixtures (no hay transacción que
  # las envuelva ni las limpie).
  self.fixture_sets = {}

  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 900 ] do |driver_opts|
    # Necesario para ejecutar Chrome dentro de contenedores Docker.
    driver_opts.add_argument("--no-sandbox")
    driver_opts.add_argument("--disable-dev-shm-usage")
    driver_opts.add_argument("--disable-gpu")
  end

  # ── Helpers de autenticación ────────────────────────────────────────────────

  # Inicia sesión a través del formulario de login (como haría un usuario real).
  # Espera a que Turbo Drive complete la redirección antes de retornar.
  def sign_in_as(user, password: "password123")
    visit new_session_url
    fill_in "Correo electrónico", with: user.email_address
    fill_in "Contraseña",         with: password
    click_on "Entrar"
    assert_no_current_path new_session_path, wait: 5
  end

  # ── Helpers de creación de datos ─────────────────────────────────────────────

  def create_inspector(email: "inspector@hive.mx", name: "Ana García", password: "password123")
    User.create!(email_address: email, name: name, password: password, role: :inspector)
  end

  def create_admin(email: "admin@hive.mx", name: "Admin Hive", password: "password123")
    User.create!(email_address: email, name: name, password: password, role: :admin)
  end

  # ── Limpieza (antes y después de cada test) ──────────────────────────────────
  #
  # El callback `setup` de ApplicationSystemTestCase se registra ANTES que los
  # de las subclases. Al truncar aquí garantizamos que la DB esté limpia cuando
  # las subclases creen sus usuarios (create_admin, create_inspector, etc.).
  # Los fixtures del worker paralelo ya fueron cargados por `before_setup`; los
  # eliminamos aquí.

  setup    { truncate_tables }
  teardown { truncate_tables }

  private

  TRUNCATE_TABLES = %w[sessions comments records active_storage_attachments active_storage_blobs users].freeze

  def truncate_tables
    ActiveRecord::Base.connection.execute(
      "TRUNCATE #{TRUNCATE_TABLES.join(', ')} RESTART IDENTITY CASCADE"
    )
  end
end

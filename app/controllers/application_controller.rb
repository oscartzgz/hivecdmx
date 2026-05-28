class ApplicationController < ActionController::Base
  include Authentication
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  private

  def require_admin
    redirect_to root_path, alert: "Acceso restringido." unless Current.user&.admin?
  end
end

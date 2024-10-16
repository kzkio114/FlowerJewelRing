class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_dashboards_path
    else
      dashboards_path
    end
  end
end
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_dashboard_path # 管理者がログイン後にリダイレクトされるパス
    else
      dashboard_path # 一般ユーザーがログイン後にリダイレクトされるパス
    end
  end
end
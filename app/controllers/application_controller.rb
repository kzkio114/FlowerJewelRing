class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  private

  def after_sign_in_path_for(resource)
    dashboard_path # ユーザーがログイン後にリダイレクトされるパス
  end
end
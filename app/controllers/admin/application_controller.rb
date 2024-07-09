class Admin::ApplicationController < ApplicationController
  before_action :verify_admin

  private

  def verify_admin
    if params[:organization_id].present?
      @organization = Organization.find_by(id: params[:organization_id])
      unless @organization && (current_user.admin_for?(@organization) || current_user.super_admin?)
        redirect_to root_path, alert: 'アクセス権限がありません。'
      end
    else
      unless current_user.super_admin?
        redirect_to root_path, alert: 'アクセス権限がありません。'
      end
    end
  end
end

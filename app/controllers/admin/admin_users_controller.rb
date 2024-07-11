class Admin::AdminUsersController < Admin::ApplicationController
  before_action :set_admin_user, only: [:edit, :update, :destroy]
  include ActionView::RecordIdentifier  # Turbo Streamsで使用するために追加

  def index
    @admin_users = AdminUser.all
  end

  def edit
  end

  def update
    if @admin_user.update(admin_user_params)
      redirect_to admin_admin_users_path, notice: '管理者ユーザーが更新されました。'
    else
      render :edit
    end
  end

  def destroy
    @admin_user.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@admin_user)) }
      format.html { redirect_to admin_admin_users_path, notice: '管理者ユーザーが削除されました。' }
    end
  end

  private

  def set_admin_user
    @admin_user = AdminUser.find(params[:id])
  end

  def admin_user_params
    params.require(:admin_user).permit(:user_id, :organization_id, :admin_role)
  end
end

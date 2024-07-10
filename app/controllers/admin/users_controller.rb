# app/controllers/admin/users_controller.rb
module Admin
  class UsersController < ApplicationController
    include ActionView::RecordIdentifier  # 追加

    before_action :set_user, only: [:destroy]

    def destroy
      @user.destroy
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@user)) }
        format.html { redirect_to admin_dashboard_path, notice: 'ユーザーを削除しました。' }
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end

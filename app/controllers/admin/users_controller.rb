# app/controllers/admin/users_controller.rb
module Admin
  class UsersController < ApplicationController
    include ActionView::RecordIdentifier

    before_action :set_user, only: [:destroy]

    def destroy
      ActiveRecord::Base.transaction do
        @user.sent_chats.destroy_all
        @user.received_chats.destroy_all
        @user.destroy
      end
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@user)) }
        format.html { redirect_to admin_dashboards_path, notice: 'ユーザーを削除しました。' }
      end
    rescue ActiveRecord::RecordNotDestroyed => e
      respond_to do |format|
        format.html { redirect_to admin_dashboards_path, alert: 'ユーザーの削除に失敗しました。' }
      end
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end

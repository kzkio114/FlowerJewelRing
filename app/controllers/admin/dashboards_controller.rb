class Admin::DashboardsController < Admin::ApplicationController
  def index
    @admin_users = AdminUser.includes(:user, :organization).all
    @current_time = Time.zone.now.in_time_zone('Asia/Tokyo')
    @group_chats = GroupChat.all
    @users = User.all
    @consultations = Consultation.all
    @gifts = Gift.includes(:gift_category).all
    @gift_histories = GiftHistory.all 
    @gift_templates = GiftTemplate.includes(:gift_category).all
  end

  def destroy_user
    user = User.find(params[:id])
    user.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(user)) }
      format.html { redirect_to admin_dashboard_index_path, notice: 'ユーザーを削除しました。' }
    end
  end

  def destroy_consultation
    consultation = Consultation.find(params[:id])
    consultation.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(consultation)) }
      format.html { redirect_to admin_dashboard_index_path, notice: '相談を削除しました。' }
    end
  end

  def destroy_gift
    gift = Gift.find(params[:id])
    gift.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(gift)) }
      format.html { redirect_to admin_dashboard_index_path, notice: 'ギフトを削除しました。' }
    end
  end

  def redirect_to_dashboard
    redirect_to admin_dashboard_path
  end
end

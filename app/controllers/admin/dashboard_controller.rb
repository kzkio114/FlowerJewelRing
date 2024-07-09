class Admin::DashboardController < Admin::ApplicationController
  before_action :set_consultation, only: [:destroy_consultation]

  def index
    @admin_users = AdminUser.all
    @current_time = Time.zone.now.in_time_zone('Asia/Tokyo')
    @group_chats = GroupChat.all
    @users = User.all
    @consultations = Consultation.all
    @gifts = Gift.includes(:gift_category).all
  end

  def destroy_user
    user = User.find(params[:id])
    user.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(user) }
      format.html { redirect_to admin_dashboard_index_path, notice: 'ユーザーを削除しました。' }
    end
  end

  def destroy_consultation
    consultation = Consultation.find(params[:id])
    consultation.destroy
    set_unread_gifts_count
    set_unread_replies_count
    @consultations = Consultation.includes(:category).all
    @new_consultation = Consultation.new

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/worries_response", locals: { consultations: @consultations, consultation: @new_consultation })
        ]
      end
      format.html { redirect_to admin_dashboard_index_path, notice: '相談を削除しました。' }
    end
  end

  def destroy_gift
    gift = Gift.find(params[:id])
    gift.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(gift) }
      format.html { redirect_to admin_dashboard_index_path, notice: 'ギフトを削除しました。' }
    end
  end

  private

  def set_consultation
    @consultation = Consultation.find(params[:id])
  end

  def set_unread_gifts_count
    @unread_gifts_count = current_user.calculate_unread_gifts_count
  end

  def set_unread_replies_count
    @unread_replies_count = current_user.consultations.joins(:replies).where('replies.read = ?', false).count
  end
end

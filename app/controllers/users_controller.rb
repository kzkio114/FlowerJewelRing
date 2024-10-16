class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def user_list
    @users = User.all
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/user_response"),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count })
        ]
      end
    end
  end

  def user_list_show
    @user = User.find(params[:id])
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/user_show_response")
        ]
      end
    end
  end

  def show
    @user = User.find(params[:id])
    @sent_gifts = @user.sent_gifts
    replier_ids = @user.consultations.joins(:replies).pluck('replies.user_id').uniq
    @received_gifts_from_repliers = @user.received_gifts.where(giver_id: replier_ids)

    mark_gift_comments_and_messages_as_read(@received_gifts_from_repliers)
  end

  def edit
    @user = User.find(params[:id])
    @user.build_profile unless @user.profile
  end

  def update
    if @user.update(user_params)
      redirect_to dashboard_path, notice: 'ユーザーは正常に更新されました。'
    else
      Rails.logger.debug @user.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path, notice: 'ユーザーが正常に削除されました。'
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    unless @user && (@user == current_user || current_user.admin?)
      redirect_to root_url, alert: "Access denied."
    end
  end

  def user_params
    params.require(:user).permit(:name, :email, :display_name, profile_attributes: [:introduction, :interests])
  end

  def mark_gift_comments_and_messages_as_read(gifts)
    gifts.each do |gift|
      gift.gift_histories.where(read: false).update_all(read: true)
      gift.update(sender_message: nil) if gift.sender_message.present?
    end
  end
end

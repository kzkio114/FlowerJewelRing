class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  def show
    @user = User.find(params[:id])
    @sent_gifts = @user.sent_gifts

    # 自分の相談に対する返信者のIDを取得
    replier_ids = @user.consultations.joins(:replies).pluck('replies.user_id').uniq
    # 返信者が送ったギフトのみを取得
    @received_gifts_from_repliers = @user.received_gifts.where(giver_id: replier_ids)

    @consultations = @user.consultations.includes(:replies)
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
    redirect_to users_url, notice: 'User was successfully destroyed.'
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
end

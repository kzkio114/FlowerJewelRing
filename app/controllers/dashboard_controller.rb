class DashboardController < ApplicationController
  before_action :set_latest_replies_and_notifications, only: [:index]

  def index
    @group_chats = GroupChat.all
    @user = current_user
    @unread_gifts_count = current_user.calculate_unread_gifts_count
    @gifts = Gift.includes(:gift_category).all
    @reply_users = User.joins(:replies).distinct
  end

  private

  def set_latest_replies_and_notifications
    @latest_replies = current_user.consultations.joins(replies: :user).select('replies.*, users.name as user_name').order('replies.created_at DESC').limit(5)
  end
end

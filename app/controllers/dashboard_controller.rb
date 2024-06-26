class DashboardController < ApplicationController
  before_action :set_latest_replies_and_notifications, only: [:index]

  def index
    @group_chats = GroupChat.all
    @user = current_user
    @unread_gifts_count = current_user.calculate_unread_gifts_count
    @gifts = Gift.includes(:gift_category).all
    @reply_users = User.joins(:replies).distinct
    @latest_gifts = Gift.order(created_at: :desc).limit(5)
    @sent_gifts = @user.sent_gifts
    @received_gifts = @user.received_gifts

    @latest_gift_messages = fetch_latest_gift_messages
  end

  private

  def set_latest_replies_and_notifications
    @latest_replies = fetch_latest_replies
  end

  def fetch_latest_replies
    current_user.consultations.joins(replies: :user)
                .select('replies.*, users.name as user_name')
                .order('replies.created_at DESC')
                .limit(5)
  end

  def fetch_latest_gift_messages
    gift_messages = current_user.received_gifts.joins(:gift_histories).pluck('gift_histories.sender_message', 'gift_histories.created_at', 'gifts.id') +
                    current_user.received_gifts.pluck(:sender_message, :created_at, :id)
    gift_messages = gift_messages.reject { |message, _, _| message.blank? }
                                 .sort_by { |_, created_at, _| created_at }
                                 .reverse
                                 .first(5)
    gift_messages.map do |message, created_at, gift_id|
      gift = Gift.find(gift_id)
      { message: message, created_at: created_at, gift: gift }
    end
  end
end

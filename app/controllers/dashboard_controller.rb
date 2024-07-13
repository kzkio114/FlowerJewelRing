class DashboardController < ApplicationController
  before_action :set_latest_replies_and_notifications, only: [:index]

  def index
    @admin_users = AdminUser.includes(:user, :organization).all
    @current_time = Time.zone.now.in_time_zone('Asia/Tokyo')
    @group_chats = GroupChat.all
    @user = current_user
    @unread_gifts_count = current_user.calculate_unread_gifts_count
    @unread_replies_count = fetch_unread_replies_count
    @gifts = Gift.includes(:gift_category).all
    @reply_users = User.joins(:replies).distinct
    @latest_gifts = Gift.order(created_at: :desc).limit(5)
    @sent_gifts = @user.sent_gifts
    @received_gifts = @user.received_gifts
    @latest_gift_messages = fetch_latest_gift_messages

    if params[:query].present? && params[:query].strip.present?
      queries = params[:query].split(/[\s　]+/) # 全角スペースと半角スペースで分割
      @consultations = queries.flat_map do |q|
        Consultation.search(q, fields: [:title, :content, :category_name, :user_name], match: :word_middle)
      end.uniq
    else
      @consultations = Consultation.none
    end
  end

  def reset_gift_notifications
    replier_ids = current_user.consultations.joins(:replies).pluck('replies.user_id').uniq
    @received_gifts_from_repliers = current_user.received_gifts.where(giver_id: replier_ids)
    mark_gift_comments_and_messages_as_read(@received_gifts_from_repliers)
    redirect_to dashboard_path, notice: '通知がリセットされました。'
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

  def fetch_unread_replies_count
    current_user.consultations.joins(replies: :user)
                .where('replies.read = ?', false)
                .count
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

  def mark_gift_comments_and_messages_as_read(gifts)
    gifts.each do |gift|
      gift.gift_histories.where(read: false).update_all(read: true)
      gift.update(sender_message: nil) if gift.sender_message.present?
    end
  end
end

class ButtonsController < ApplicationController
  before_action :set_latest_replies_and_notifications, only: [:info, :menu, :close_menu, :worries, :gift_list, :gift_all, :user]

  private

  def set_unread_gifts_count
    @unread_gifts_count = current_user&.calculate_unread_gifts_count || 0
  end

  def set_unread_replies_count
    if current_user
      @unread_replies_count = current_user.consultations.joins(:replies).where('replies.read = ?', false).count || 0
    else
      @unread_replies_count = 0
    end
  end
  
  def set_latest_replies_and_notifications
    if current_user
      @latest_replies = current_user.consultations.joins(:replies, replies: :user)
                       .select('replies.*, users.name as user_name')
                       .order('replies.created_at DESC')
                       .limit(5)
    else
      # 非認証ユーザー用のサンプルデータ
      @latest_replies = [
        OpenStruct.new(content: "サンプル返信1", user_name: "サンプルユーザー1"),
        OpenStruct.new(content: "サンプル返信2", user_name: "サンプルユーザー2")
      ]
    end
  end

  def fetch_unread_replies_count
    current_user.consultations.joins(:replies).where('replies.read = ?', false).count || 0
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

  def fetch_latest_replies
    Reply.joins(:consultation, :user)
         .where(consultations: { user_id: current_user.id })
         .select('replies.*, users.name as user_name')
         .order('replies.created_at DESC')
         .limit(5)
  end
end

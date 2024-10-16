class DashboardsController < ApplicationController
  before_action :set_common_variables, only: [:index, :info, :menu, :close_menu]
  before_action :set_latest_replies_and_notifications, only: [:index, :info]

  def index; end

  def info
    @current_time = Time.zone.now
    render_turbo_response("content", "info_response", {
      gifts: @gifts,
      replies: @replies,
      reply_users: @reply_users,
      latest_gift_messages: @latest_gift_messages,
      unread_gifts_count: @unread_gifts_count,
      unread_replies_count: @unread_replies_count,
      current_time: @current_time,
      group_chats: @group_chats,
      user: @user,
      latest_gifts: @latest_gifts,
      sent_gifts: @sent_gifts,
      received_gifts: @received_gifts
    })
  end

  def menu
    render_turbo_stream_for_menu("buttons/menu/menu_buttons")
  end

  def close_menu
    render_turbo_stream_for_menu("buttons/menu/closed_menu")
  end

  def search
    if params[:query].present? && params[:query].strip.present?
      queries = params[:query].split(/[\s　]+/)
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

  def set_common_variables
    @user = current_user
    @unread_gifts_count = @user.calculate_unread_gifts_count
    @unread_replies_count = fetch_unread_replies_count
    @gifts = @user.received_gifts
    @reply_users = User.joins(:replies).distinct
    @latest_gifts = Gift.order(created_at: :desc).limit(5)
    @sent_gifts = @user.sent_gifts
    @received_gifts = @user.received_gifts
    @latest_gift_messages = fetch_latest_gift_messages
    @group_chats = GroupChat.all
    @available_gift_items = @user.received_gifts.where(sent_at: nil).distinct.pluck(:item_name)
    
    @replies = fetch_latest_replies.map do |reply|
      {
        reply: reply,
        display_name: reply.display_name
      }
    end
  end

  def set_latest_replies_and_notifications
    @latest_replies = fetch_latest_replies
  end

  def fetch_latest_replies
    Reply.joins(:consultation, :user)
         .where(consultations: { user_id: current_user.id })
         .select('replies.*, users.name as user_name')
         .order('replies.created_at DESC')
         .limit(5)
  end

  def fetch_latest_gift_messages
    gift_messages = current_user.received_gifts.joins(:gift_histories).pluck('gift_histories.sender_message', 'gift_histories.created_at', 'gifts.id') +
                    current_user.received_gifts.pluck(:sender_message, :created_at, :id)
    gift_messages.reject { |message, _, _| message.blank? }
                 .sort_by { |_, created_at, _| created_at }
                 .reverse
                 .first(5)
                 .map do |message, created_at, gift_id|
                   gift = Gift.find(gift_id)
                   { message: message, created_at: created_at, gift: Gift.find(gift_id) }
                 end
  end

  def fetch_unread_replies_count
    current_user.consultations.joins(:replies).where(replies: { read: false }).count || 0
  end

  def mark_gift_comments_and_messages_as_read(gifts)
    gifts.each do |gift|
      gift.gift_histories.where(read: false).update_all(read: true)
      gift.update(sender_message: nil) if gift.sender_message.present?
    end
  end

  def render_turbo_response(target, partial, locals = {})
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(target, partial: partial, locals: locals)
      end
    end
  end

  def render_turbo_stream_for_menu(menu_partial)
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("menu", partial: menu_partial),
          turbo_stream.replace("content", partial: "buttons/response"),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count })
        ]
      end
    end
  end
end

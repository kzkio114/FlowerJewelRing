class ButtonsController < ApplicationController
  before_action :set_unread_gifts_count, except: [:login, :enter_app, :tos, :pp]
  before_action :set_unread_replies_count, except: [:login, :enter_app, :tos, :pp]
  before_action :set_latest_replies_and_notifications, only: [:info, :menu, :close_menu, :worries, :gift_list, :gift_all, :user]

  def info
    @current_time = Time.zone.now.in_time_zone('Asia/Tokyo')
    @group_chats = GroupChat.all
    @user = current_user
    @unread_gifts_count = current_user.calculate_unread_gifts_count
    @unread_replies_count = fetch_unread_replies_count
    @gifts = current_user.received_gifts # 現在のユーザーが受け取ったギフトのみを取得
    @reply_users = User.joins(:replies).distinct
    @latest_gifts = Gift.order(created_at: :desc).limit(5)
    @sent_gifts = @user.sent_gifts
    @received_gifts = @user.received_gifts
    @latest_gift_messages = fetch_latest_gift_messages

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/info_response", locals: { gifts: @gifts, reply_users: @reply_users, latest_gift_messages: @latest_gift_messages, unread_gifts_count: @unread_gifts_count, unread_replies_count: @unread_replies_count })
        ]
      end
    end
  end

  def enter_app
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("response_area", partial: "buttons/enter_app_response")
        ]
      end
    end
  end

  def tos
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("response_area", partial: "buttons/tos_response")
        ]
      end
    end
  end

  def pp
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("response_area", partial: "buttons/pp_response")
        ]
      end
    end
  end

  def login
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("response_area", partial: "buttons/login_response"),
          turbo_stream.replace("login_button", partial: "buttons/without_login_button"),
          turbo_stream.replace("content", partial: "buttons/menu/trial_login_response")
        ]
      end
    end
  end

  def menu
    @group_chats = GroupChat.all
    set_unread_gifts_count
    set_unread_replies_count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("menu", partial: "buttons/menu/menu_buttons"),
          turbo_stream.replace("content", partial: "buttons/response"),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count })
        ]
      end
    end
  end

  def close_menu
    set_unread_gifts_count
    set_unread_replies_count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("menu", partial: "buttons/menu/closed_menu"),
          turbo_stream.replace("content", partial: "buttons/response"),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count })
        ]
      end
    end
  end

  def worries
    if params[:category_id]
      @consultations = Consultation.includes(:category).where(category_id: params[:category_id])
    else
      @consultations = Consultation.includes(:category).all
    end
    @consultation = Consultation.new
    set_unread_gifts_count
    set_unread_replies_count
  
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/worries_response", locals: { consultations: @consultations, consultation: @consultation }),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count })
        ]
      end
    end
  end

  def consultations_category
    if params[:category_id]
      @consultations = Consultation.includes(:category).where(category_id: params[:category_id], completed: true)
    else
      @consultations = Consultation.includes(:category).all
    end

    set_unread_gifts_count
    set_unread_replies_count

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/consultations_category", locals: { consultations: @consultations })
        ]
      end
    end
  end

  def consultations_response
    @consultation = Consultation.find(params[:id])
    if @consultation.user == current_user
      @replies = @consultation.replies
    else
      @replies = @consultation.replies.where(tone: @consultation.desired_reply_tone)
    end
    set_unread_gifts_count
    set_unread_replies_count
    respond_to do |format|
      format.html { redirect_to @consultation }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('content', partial: 'buttons/menu/consultations_response', locals: { consultation: @consultation, replies: @replies })
      end
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to consultations_path, alert: "指定された相談が見つかりません。"
  end

  def consultations_destroy
    @consultation = Consultation.find(params[:id])
    @consultation.destroy
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
    end
  end

  def consultations_detail
    @consultation = Consultation.includes(replies: :user).find(params[:id])
    @consultations = Consultation.includes(:category).all
    if @consultation.user == current_user
      @filter_tone = params[:filter_tone] || @consultation.desired_reply_tone
    else
      @filter_tone = params[:filter_tone].presence
    end
    set_unread_gifts_count
    set_unread_replies_count
    respond_to do |format|
      format.turbo_stream do
        if @consultation.user == current_user
          render turbo_stream: turbo_stream.replace("content", partial: "buttons/menu/consultations_detail", locals: { consultation: @consultation, filter_tone: @filter_tone })
        else
          render turbo_stream: turbo_stream.replace("content", partial: "buttons/menu/consultations_detail_all", locals: { consultation: @consultation, filter_tone: @filter_tone })
        end
      end
    end
  end

  def consultations_destroy_reply
    @consultation = Consultation.includes(replies: :user).find(params[:consultation_id])
    @reply = @consultation.replies.find(params[:reply_id])
    @reply.destroy
    set_unread_gifts_count
    set_unread_replies_count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("reply_#{@reply.id}"),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count })
        ]
      end
      format.html { redirect_to @consultation, notice: 'Reply was successfully deleted.' }
    end
  end

  def gift_list
    @total_sender_messages_count = GiftHistory.where.not(sender_message: [nil, ""]).count
    set_unread_gifts_count
    set_unread_replies_count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/gift_list_response", locals: { total_sender_messages_count: @total_sender_messages_count }),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count })
        ]
      end
    end
  end

  def gift_all
    @gift_templates = GiftTemplate.includes(:gift_category).all
    set_unread_gifts_count
    set_unread_replies_count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/gift_all_response", locals: { gift_templates: @gift_templates }),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count })
        ]
      end
    end
  end
  

  def send_gift_response
    @my_consultations = Consultation.where(user_id: current_user.id)
    replier_ids = @my_consultations.joins(:replies).pluck('replies.user_id').uniq
    @reply_users = User.where(id: replier_ids)
    @gifts = current_user.received_gifts # 現在のユーザーが受け取ったギフトのみを取得
    set_unread_gifts_count
    set_unread_replies_count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "content",
          partial: "buttons/menu/send_gift_response",
          locals: { gifts: @gifts, reply_users: @reply_users }
        )
      end
    end
  end

  def user
    @users = User.all
    set_unread_gifts_count
    set_unread_replies_count
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

  def user_show
    @user = User.find(params[:id])
    set_unread_gifts_count
    set_unread_replies_count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/user_show_response")
        ]
      end
    end
  end

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
end

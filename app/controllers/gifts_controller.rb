class GiftsController < ApplicationController
  before_action :set_gift, only: [:show, :edit, :update, :destroy, :send_gift]
  before_action :set_og_tags, only: [:show, :send_gift] # OGT設定

  def index
    @gifts = Gift.includes(:gift_category).where(sent_at: nil)
  end

  def gift_list
    @total_sender_messages_count = GiftHistory.where.not(sender_message: [nil, ""]).count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: " gift_list_response", locals: { total_sender_messages_count: @total_sender_messages_count }),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count })
        ]
      end
    end
  end

  def gift_all
    @gift_templates = GiftTemplate.includes(:gift_category).all
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: " gift_all_response", locals: { gift_templates: @gift_templates }),
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
    @gifts = current_user.received_gifts
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "content",
          partial: " send_gift_response",
          locals: { gifts: @gifts, reply_users: @reply_users }
        )
      end
    end
  end

  def show; end

  def new
    @gift = Gift.new
  end

  def create
    @gift = Gift.new(gift_params)
    @gift.giver = current_user
    @user = current_user
  
    reply_id = params[:gift][:reply_id]
    if reply_id.present?
      @reply = Reply.find(reply_id)
      @gift.reply = @reply
      @gift.anonymous = true if @reply.anonymous
    end
  
    gift_template = GiftTemplate.find_by(name: @gift.item_name)
    if gift_template
      @gift.gift_category = gift_template.gift_category
    else
      Rails.logger.error("Gift template not found for item_name: #{@gift.item_name}")
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("error-message", partial: "shared/error_message", locals: { message: "ギフトテンプレートが見つかりませんでした: #{@gift.item_name}" })
          ]
        end
      end
      return
    end
  
    if @gift.save
      redirect_to @gift, notice: 'Gift was successfully created.'
    else
      Rails.logger.error("Gift creation failed: #{@gift.errors.full_messages.join(", ")}")
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("error-message", partial: "shared/error_message", locals: { message: "ギフトを送信できませんでした: #{@gift.errors.full_messages.join(", ")}" })
          ]
        end
      end
    end
  end
  

  def edit; end

  def update
    if @gift.update(gift_params)
      redirect_to @gift, notice: 'Gift was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @gift.destroy
    redirect_to gifts_url, notice: 'Gift was successfully destroyed.'
  end

  def send_gift
    @user = current_user
    @gift = Gift.find(params[:id])
    @gift.giver_id = current_user.id
    @gift.receiver = User.find_by(id: params[:receiver_id])
    @gift.assign_attributes(gift_params)
  
    if @gift.receiver.nil?
      Rails.logger.info("Receiver not found")
      return
    end
  
    unread_replies_exist = unread_replies_exist?
  
    if unread_replies_exist
      latest_reply = Reply.where(consultation_id: @gift.receiver.consultations.pluck(:id))
                          .order(created_at: :desc)
                          .first
      if latest_reply&.anonymous?
        @gift.anonymous = true
      end
  
      if @gift.save
        if @gift.reply.present?
          @gift.reply.increment!(:sent_count)
        end
  
        mark_replies_as_read
        @gift.update(sender_message: "", sent_at: Time.current)
        update_response_data
        send_response
      else
        log_errors
      end
    else
      respond_to_unread_error
    end
  end
  

  private

  def set_gift
    @gift = Gift.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to gifts_path, alert: "指定されたギフトが見つかりません。"
  end

  def gift_params
    params.require(:gift).permit(:receiver_id, :item_name, :description, :color, :sender_message, :anonymous, :reply_id)
  end

  def unread_replies_exist?
    Reply.joins(:consultation)
         .where(consultations: { user_id: @gift.giver_id })
         .where(user_id: @gift.receiver_id, read: false)
         .exists?
  end

  def process_gift_send
    if @gift.save
      mark_replies_as_read
      @gift.update(sender_message: "", sent_at: Time.current)
      update_response_data
      send_response
    else
      log_errors
    end
  end

  def mark_replies_as_read
    replies_to_mark_read = Reply.joins(:consultation)
                                .where(consultations: { user_id: @gift.giver_id })
                                .where(user_id: @gift.receiver_id, read: false)
                                .order(created_at: :desc)
                                .first
    replies_to_mark_read.update(read: true) if replies_to_mark_read
  end

  def send_response
    @user ||= current_user
    @gifts = @user.received_gifts
  
    reply_id = @gift.reply.id if @gift.reply.present?
    
    @replies = @user.consultations.joins(:replies).select('replies.*, consultations.id as consultation_id').order('replies.created_at DESC')
    @unread_gifts_count = current_user.calculate_unread_gifts_count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("reply_#{reply_id}"),
          turbo_stream.replace("unread-replies-count", partial: "layouts/unread_replies_count", locals: { user: @user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count }),
          turbo_stream.replace("gifts", partial: "gifts/gift", locals: content_locals)
        ]
      end
    end
  end

  def log_errors
    Rails.logger.info(@gift.errors.full_messages.join(", "))
  end

  def respond_to_unread_error
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("error-message", partial: "shared/error_message", locals: { message: "未読の返信がないため、ギフトを送信できません。" })
        ]
      end
    end
  end

  def update_response_data
    @my_consultations = Consultation.where(user_id: current_user.id)
    replier_ids = @my_consultations.joins(:replies).pluck('replies.user_id').uniq
    @reply_users = User.where(id: replier_ids)
    @gifts = Gift.where(receiver_id: current_user.id)
    @unread_gifts_count = current_user.calculate_unread_gifts_count
    @latest_replies = fetch_latest_replies
    @latest_gift_messages = fetch_latest_gift_messages
    @current_time = Time.zone.now.in_time_zone('Asia/Tokyo')
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
    gift_messages.reject { |message, _, _| message.blank? }
                 .sort_by { |_, created_at, _| created_at }
                 .reverse
                 .first(5)
                 .map { |message, created_at, gift_id| { message: message, created_at: created_at, gift: Gift.find(gift_id) } }
  end

  def content_partial
    params[:return_to] == "info" ? "dashboards/info_response" : "send_gift_response"
  end

  def content_locals
    {
      gifts: @gifts,
      reply_users: @reply_users,
      latest_gift_messages: @latest_gift_messages,
      current_time: @current_time
    }
  end

  def set_og_tags
    @twitter_title = @gift.item_name
    @twitter_description = @gift.description
    @twitter_image = @gift.image_url.present? ? url_for(@gift.image_url) : url_for('/assets/top.png')
  end
end

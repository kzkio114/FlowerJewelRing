class GiftsController < ApplicationController
  before_action :set_gift, only: [:show, :edit, :update, :destroy, :send_gift]

  def index
    @gifts = Gift.includes(:gift_category).where(sent_at: nil) # 未送付のギフトのみ表示
  end

  def show
  end

  def new
    @gift = Gift.new
  end

  def create
    @gift = Gift.new(gift_params)
    @gift.giver = current_user # 現在ログインしているユーザーをgiverに設定
    if @gift.save
      redirect_to @gift, notice: 'Gift was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

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
    @gift.receiver = User.find_by(id: params[:gift][:receiver_id])
    @gift.assign_attributes(gift_params)

    if @gift.receiver.nil?
      Rails.logger.info("Receiver not found")
      return
    end

    unread_replies_exist = Reply.joins(:consultation)
                                .where(consultations: { user_id: @gift.giver_id })
                                .where(user_id: @gift.receiver_id, read: false)
                                .exists?

    if unread_replies_exist
      if @gift.save
          # ギフトを無効化する
        replies_to_mark_read = Reply.joins(:consultation)
                                    .where(consultations: { user_id: @gift.giver_id })
                                    .where(user_id: @gift.receiver_id, read: false)
                                    .order(created_at: :desc)
                                    .first
        replies_to_mark_read.update(read: true) if replies_to_mark_read

        @gift.update(active: false, sent_at: Time.current)

        # 相手に新しいギフトを作成
        Gift.create!(
          gift_category: @gift.gift_category,
          item_name: @gift.item_name,
          description: @gift.description,
          color: @gift.color,
          image_url: @gift.image_url,
          giver: @gift.receiver, # 相手がこのギフトを使用できるように設定
          receiver: nil, # これは相手が使うので最初は空
          gift_template: @gift.gift_template
        )

        # その他の処理を実行
        assign_random_gift_to_user(@gift.giver_id)
        update_response_data

        respond_to do |format|
          format.turbo_stream do
            render turbo_stream: [
              turbo_stream.replace("unread-replies-count", partial: "layouts/unread_replies_count", locals: { user: current_user }),
              turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count }),
              if params[:return_to] == "info"
                turbo_stream.replace("content", partial: "buttons/menu/info_response", locals: { gifts: @gifts, reply_users: @reply_users, latest_gift_messages: @latest_gift_messages, current_time: @current_time })
              else
                turbo_stream.replace("content", partial: "buttons/menu/send_gift_response", locals: { gifts: @gifts, reply_users: @reply_users })
              end
            ]
          end
        end
      else
        Rails.logger.info(@gift.errors.full_messages.join(", "))
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("error-message", partial: "shared/error_message", locals: { message: "未読の返信がないため、ギフトを送信できません。" })
          ]
        end
      end
    end
  end

  private

  def set_gift
    @gift = Gift.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to gifts_path, alert: "指定されたギフトが見つかりません。"
  end

  def gift_params
    params.require(:gift).permit(:receiver_id, :item_name, :description, :color, :sender_message)
  end

  def assign_random_gift_to_user(user_id)
    new_gifts = Gift.order("RANDOM()").limit(1)
    new_gifts.each do |new_gift|
      new_gift.update!(giver_id: user_id, sent_at: nil, receiver_id: nil)
    end
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

  def update_response_data
    @my_consultations = Consultation.where(user_id: current_user.id)
    replier_ids = @my_consultations.joins(:replies).pluck('replies.user_id').uniq
    @reply_users = User.where(id: replier_ids)

    # 全てのギフトを取得
    @gifts = Gift.includes(:gift_category).all

    # 未読のギフト数を計算
    @unread_gifts_count = current_user.calculate_unread_gifts_count

    # 最新の返信を設定
    @latest_replies = current_user.consultations.joins(replies: :user).select('replies.*, users.name as user_name').order('replies.created_at DESC').limit(5)

    # 最新のギフトメッセージを取得
    @latest_gift_messages = fetch_latest_gift_messages

    @current_time = Time.zone.now.in_time_zone('Asia/Tokyo')
  end
end

class GiftsController < ApplicationController
  before_action :set_gift, only: [:show, :edit, :update, :destroy, :send_gift]

  # ギフト一覧を表示するアクション
  def index
    # まだ送信されていないギフトを表示
    @gifts = Gift.includes(:gift_category).where(sent_at: nil)
  end

  # ギフトの詳細を表示するアクション
  def show
  end

  # 新しいギフトを作成するためのアクション
  def new
    @gift = Gift.new
  end

  # ギフトを保存するアクション
  def create
    @gift = Gift.new(gift_params)
    @gift.giver = current_user # 現在ログインしているユーザーを送信者に設定
    if @gift.save
      redirect_to @gift, notice: 'Gift was successfully created.'
    else
      render :new
    end
  end

  # ギフトの編集フォームを表示するアクション
  def edit
  end

  # ギフトの更新を行うアクション
  def update
    if @gift.update(gift_params)
      redirect_to @gift, notice: 'Gift was successfully updated.'
    else
      render :edit
    end
  end

  # ギフトを削除するアクション
  def destroy
    @gift.destroy
    redirect_to gifts_url, notice: 'Gift was successfully destroyed.'
  end

  # ギフトを送信するアクション
  def send_gift
    @user = current_user
    @gift = Gift.find(params[:id]) # ギフトをIDで検索
    @gift.giver_id = current_user.id # 現在のユーザーを送信者として設定
    @gift.receiver = User.find_by(id: params[:gift][:receiver_id]) # 受信者を設定
    @gift.assign_attributes(gift_params) # ギフトの属性を更新

    # 受信者が存在しない場合はログに記録し、処理を中断
    if @gift.receiver.nil?
      Rails.logger.info("Receiver not found")
      return
    end

    # 未読の返信が存在するかを確認
    unread_replies_exist = Reply.joins(:consultation)
                                .where(consultations: { user_id: @gift.giver_id })
                                .where(user_id: @gift.receiver_id, read: false)
                                .exists?

    # 未読の返信が存在する場合はギフトを送信する処理を実行
    if unread_replies_exist
      process_gift_send
    else
      respond_to_unread_error # 未読の返信がない場合のエラー処理
    end
  end

  private

  # ギフトをセットするメソッド（例外処理付き）
  def set_gift
    @gift = Gift.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to gifts_path, alert: "指定されたギフトが見つかりません。"
  end

  # ギフトのパラメータを許可するメソッド
  def gift_params
    params.require(:gift).permit(:receiver_id, :item_name, :description, :color, :sender_message)
  end

  # ギフト送信のメイン処理を行うメソッド
  def process_gift_send
    if @gift.save
      mark_replies_as_read # 返信を既読にする
      # メッセージをリセットしてギフトを再利用可能にする
      @gift.update(sender_message: "", sent_at: Time.current)
      assign_random_gift_to_user(@gift.giver_id) # 送信者にランダムなギフトを割り当て
      update_response_data # レスポンスデータを更新
      send_response # レスポンスを送信
      Rails.logger.info(@gift.errors.full_messages.join(", ")) # エラーをログに記録
    end
  end

  # 返信を既読にするメソッド
  def mark_replies_as_read
    replies_to_mark_read = Reply.joins(:consultation)
                                .where(consultations: { user_id: @gift.giver_id })
                                .where(user_id: @gift.receiver_id, read: false)
                                .order(created_at: :desc)
                                .first
    replies_to_mark_read.update(read: true) if replies_to_mark_read
  end

  # レスポンスを送信するメソッド
  def send_response
    @my_consultations = Consultation.where(user_id: current_user.id)
    replier_ids = @my_consultations.joins(:replies).pluck('replies.user_id').uniq
    @reply_users = User.where(id: replier_ids)
    @gifts = current_user.received_gifts # 現在のユーザーが受け取ったギフトのみを取得
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("unread-replies-count", partial: "layouts/unread_replies_count", locals: { user: current_user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count }),
          turbo_stream.replace("content",partial: "buttons/menu/send_gift_response",locals: { gifts: @gifts, reply_users: @reply_users })
        ]
      end
    end
  end

  # 送信先のパーシャルを決定するメソッド
  def content_partial
    params[:return_to] == "info" ? "buttons/menu/info_response" : "buttons/menu/send_gift_response"
  end

  # レスポンスのローカル変数を設定するメソッド
  def content_locals
    {
      gifts: @gifts,
      reply_users: @reply_users,
      latest_gift_messages: @latest_gift_messages,
      current_time: @current_time
    }
  end

  # 未読の返信がない場合のエラーレスポンスを返すメソッド
  def respond_to_unread_error
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("error-message", partial: "shared/error_message", locals: { message: "未読の返信がないため、ギフトを送信できません。" })
        ]
      end
    end
  end

  # ランダムなギフトをユーザーに割り当てるメソッド
  def assign_random_gift_to_user(user_id)
    new_gift = Gift.order("RANDOM()").limit(1).first
    new_gift.update!(giver_id: user_id, sent_at: nil, receiver_id: nil) if new_gift
  end

  # 最新のギフトメッセージを取得するメソッド
  def fetch_latest_gift_messages
    gift_messages = current_user.received_gifts.joins(:gift_histories).pluck('gift_histories.sender_message', 'gift_histories.created_at', 'gifts.id') +
                    current_user.received_gifts.pluck(:sender_message, :created_at, :id)
    gift_messages.reject { |message, _, _| message.blank? }
                 .sort_by { |_, created_at, _| created_at }
                 .reverse
                 .first(5)
                 .map { |message, created_at, gift_id| { message: message, created_at: created_at, gift: Gift.find(gift_id) } }
  end

  # レスポンスデータを更新するメソッド
  def update_response_data
    @my_consultations = Consultation.where(user_id: current_user.id)
    replier_ids = @my_consultations.joins(:replies).pluck('replies.user_id').uniq
    @reply_users = User.where(id: replier_ids)

    @gifts = Gift.includes(:gift_category).where(active: true, sent_at: nil)
    @unread_gifts_count = current_user.calculate_unread_gifts_count
    @latest_replies = fetch_latest_replies
    @latest_gift_messages = fetch_latest_gift_messages
    @current_time = Time.zone.now.in_time_zone('Asia/Tokyo')
  end

  # 最新の返信を取得するメソッド
  def fetch_latest_replies
    current_user.consultations.joins(replies: :user)
                .select('replies.*, users.name as user_name')
                .order('replies.created_at DESC')
                .limit(5)
  end
end

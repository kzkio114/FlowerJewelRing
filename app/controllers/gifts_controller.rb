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

  # app/controllers/gifts_controller.rb
  def send_gift
    @gift = Gift.find(params[:id])
    @gift.giver_id = current_user.id
    @gift.receiver = User.find_by(id: params[:gift][:receiver_id])  # 送信先のユーザーIDをパラメータから取得# 送信先のユーザーIDをパラメータから取得
    @gift.assign_attributes(gift_params)  # gift_paramsからの値でギフトを更新

    if @gift.receiver.nil?
      Rails.logger.info("Receiver not found")
      return
    end
  
    if @gift.save
      @gifts = Gift.includes(:gift_category).where(receiver_id: current_user.id)  # ユーザーが受け取ったギフトを取得
      @total_sent_gifts = Gift.where(giver_id: current_user.id).count
      @total_sent_gifts_all_users = Gift.where.not(giver_id: nil).count
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/send_gift_response", locals: { gifts: @gifts })
          ]
        end
      end
    else
      Rails.logger.info(@gift.errors.full_messages.join(", "))
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
end

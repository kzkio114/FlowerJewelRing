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
  # app/controllers/gifts_controller.rb
  def send_gift
    @gift = Gift.find(params[:id])
    if @gift.update(gift_params.merge(sent_at: Time.current))
      respond_to do |format|
        format.turbo_stream do
          # 成功時にギフトカードの場所に成功メッセージを表示
          render turbo_stream: turbo_stream.replace("gift_card_#{params[:id]}", partial: "gifts/send_gift_success", locals: { gift: @gift })
        end
        format.html { redirect_to gifts_path, notice: 'ギフトとメッセージを送信しました。' }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("send_gift_frame_#{params[:id]}", partial: "gifts/send_kudo_error", locals: { gift: @gift })
        end
        format.html { render :show, alert: 'ギフトの送信に失敗しました。' }
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
    params.require(:gift).permit(:giver_id, :receiver_id, :gift_category_id, :message, :sent_at)
  end
end

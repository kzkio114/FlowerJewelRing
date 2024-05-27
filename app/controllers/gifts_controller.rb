class GiftsController < ApplicationController
  before_action :set_gift, only: [:show, :edit, :update, :destroy]

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

  private

  def send_gift
    @gift = Gift.find(params[:id])
    @gift.update(sent_at: Time.current) # 現在の時刻を送付時刻として記録
    redirect_to @gift, notice: 'Gift was successfully sent.'
  end

    def gift_params
      params.require(:gift).permit(:giver_id, :receiver_id, :gift_category_id, :message, :sent_at)
    end
end

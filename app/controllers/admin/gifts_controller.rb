# app/controllers/admin/gifts_controller.rb
module Admin
  class GiftsController < ApplicationController
    include ActionView::RecordIdentifier  # 追加

    before_action :set_gift, only: [:destroy]

    def destroy
      @gift.destroy
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@gift)) }
        format.html { redirect_to admin_dashboard_path, notice: 'ギフトを削除しました。' }
      end
    end

    private

    def set_gift
      @gift = Gift.find(params[:id])
    end
  end
end

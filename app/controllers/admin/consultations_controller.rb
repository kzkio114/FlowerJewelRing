# app/controllers/admin/consultations_controller.rb
module Admin
  class ConsultationsController < ApplicationController
    include ActionView::RecordIdentifier  # 追加

    before_action :set_consultation, only: [:destroy]

    def destroy
      @consultation.destroy
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove(dom_id(@consultation)) }
        format.html { redirect_to admin_dashboard_path, notice: '相談を削除しました。' }
      end
    end

    private

    def set_consultation
      @consultation = Consultation.find(params[:id])
    end
  end
end

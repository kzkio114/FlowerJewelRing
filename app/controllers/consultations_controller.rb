class ConsultationsController < ApplicationController
  before_action :set_consultation, only: [:show, :edit, :update, :destroy]

  # GET /consultations
  def index
    @consultations = Consultation.all
  end

  # GET /consultations/1
  def show
    @consultation = Consultation.includes(replies: :user).find(params[:id])
    @consultations = Consultation.includes(:category).all
    respond_to do |format|
      format.html  # show.html.erb で @consultation を使用　
      format.turbo_stream { render turbo_stream: turbo_stream.replace('content', partial: 'buttons/menu/worries_response', locals: { consultations: @consultations, consultation: @consultation }) }
    end
  rescue ActiveRecord::RecordNotFound
    respond_to do |format|
      format.html { redirect_to root_path, alert: "指定された相談が見つかりません。" }
      format.turbo_stream { render turbo_stream: turbo_stream.replace("content", partial: "shared/not_found") }
    end
  end

  # GET /consultations/new
  def new
    @consultation = Consultation.new
  end

  # GET /consultations/1/edit
  def edit
  end

  # POST /consultations
  def create
    @consultation = Consultation.new(consultation_params)

    respond_to do |format|
      if @consultation.save
        format.html { redirect_to @consultation, notice: 'コンサルテーションが正常に作成されました。' }
        format.turbo_stream do
          @consultations = Consultation.includes(:category).all
          render turbo_stream: turbo_stream.replace('content', partial: 'buttons/menu/worries_response', locals: { consultations: @consultations, consultation: Consultation.new })
        end
      else
        format.html { render :new }
        format.turbo_stream do
          @consultations = Consultation.includes(:category).all
          render turbo_stream: turbo_stream.replace('content', partial: 'buttons/menu/worries_response', locals: { consultations: @consultations, consultation: @consultation })
        end
      end
    end
  end

  # PATCH/PUT /consultations/1
  def update
    if @consultation.update(consultation_params)
      redirect_to @consultation, notice: 'コンサルテーションが正常に更新されました。'
    else
      render :edit
    end
  end

  # DELETE /consultations/1
  def destroy
    @consultation.destroy
    redirect_to consultations_url, notice: 'コンサルテーションが正常に削除されました。'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_consultation
      @consultation = Consultation.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def consultation_params
      params.require(:consultation).permit(:user_id, :category_id, :title, :content)
    end
end

class ConsultationsController < ApplicationController
  before_action :set_consultation, only: [:show, :edit, :update, :destroy]

  def index
    @consultations = Consultation.all
  end

  def worries
    if params[:category_id]
      @consultations = Consultation.includes(:category).where(category_id: params[:category_id])
    else
      @consultations = Consultation.includes(:category).all
    end
    @consultation = Consultation.new

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "worries_response", locals: { consultations: @consultations, consultation: @consultation }),
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
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "consultations_category", locals: { consultations: @consultations })
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
    respond_to do |format|
      format.html { redirect_to @consultation }
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('content', partial: 'consultations_response', locals: { consultation: @consultation, replies: @replies })
      end
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to consultations_path, alert: "指定された相談が見つかりません。"
  end

  def consultations_detail
    @consultation = Consultation.includes(replies: :user).find(params[:id])
    @consultations = Consultation.includes(:category).all
    if @consultation.user == current_user
      @filter_tone = params[:filter_tone] || @consultation.desired_reply_tone
    else
      @filter_tone = params[:filter_tone].presence
    end
    respond_to do |format|
      format.turbo_stream do
        if @consultation.user == current_user
          render turbo_stream: turbo_stream.replace("content", partial: "consultations_detail", locals: { consultation: @consultation, filter_tone: @filter_tone })
        else
          render turbo_stream: turbo_stream.replace("content", partial: "consultations_detail_all", locals: { consultation: @consultation, filter_tone: @filter_tone })
        end
      end
    end
  end


  def new
    @consultation = Consultation.new
  end


  def edit
  end


  def create
    @consultation = Consultation.new(consultation_params)

    respond_to do |format|
      if @consultation.save
        format.html { redirect_to @consultation, notice: 'コンサルテーションが正常に作成されました。' }
        format.turbo_stream do
          @consultations = Consultation.includes(:category).all
          render turbo_stream: turbo_stream.replace('content', partial: 'worries_response', locals: { consultations: @consultations, consultation: Consultation.new })
        end
      else
        format.html { render :new }
        format.turbo_stream do
          @consultations = Consultation.includes(:category).all
          render turbo_stream: turbo_stream.replace('content', partial: 'worries_response', locals: { consultations: @consultations, consultation: @consultation })
        end
      end
    end
  end


  def update
    if @consultation.update(consultation_params)
      redirect_to @consultation, notice: 'コンサルテーションが正常に更新されました。'
    else
      render :edit
    end
  end

  def destroy
    @consultation = Consultation.find(params[:id])
    @consultation.destroy
    @consultations = Consultation.includes(:category).all
    @new_consultation = Consultation.new

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "worries_response", locals: { consultations: @consultations, consultation: @new_consultation })
        ]
      end
    end
  end

  private

    def set_consultation
      @consultation = Consultation.find(params[:id])
    end

    def consultation_params
      params.require(:consultation).permit(:title, :content, :category_id, :reply_tone, :desired_reply_tone, :display_choice, :user_id)
    end
end

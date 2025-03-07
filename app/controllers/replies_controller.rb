class RepliesController < ApplicationController
  before_action :set_consultation, only: [:new, :create, :destroy]

  def new
    @reply = @consultation.replies.build
  end

  def create
    @reply = @consultation.replies.build(reply_params)
    @reply.user = current_user

    respond_to do |format|
      if @reply.save
        format.turbo_stream do
          if @consultation.user == current_user
            render turbo_stream: [
              turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
              turbo_stream.replace('content', partial: 'consultations/consultations_detail', locals: { consultation: @consultation, filter_tone: nil })
            ]
          else
            render turbo_stream: [
              turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
              turbo_stream.replace('content', partial: 'consultations/consultations_detail_all', locals: { consultation: @consultation, filter_tone: params[:filter_tone] })
            ]
          end
        end
        format.html { redirect_to @consultation, notice: 'Reply was successfully created.' }
      else
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace('reply_form', partial: 'replies/form', locals: { consultation: @consultation, reply: @reply })
        end
        format.html { render :new }
        format.json { render json: @reply.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @reply = @consultation.replies.find(params[:id])
    @reply.destroy
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("reply_#{@reply.id}"),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count })
        ]
      end
      format.html { redirect_to @consultation, notice: 'Reply was successfully deleted.' }
    end
  end

  private

  def set_consultation
    @consultation = Consultation.find(params[:consultation_id])
  end

  def reply_params
    params.require(:reply).permit(:content, :tone, :display_choice)
  end
end

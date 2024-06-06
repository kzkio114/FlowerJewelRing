class RepliesController < ApplicationController
    def new
        @consultations = Consultation.find(params[:consultation_id])
        @reply = @consultations.replies.build
    end

   def create
  @reply = Reply.new(reply_params)
  @reply.user_id = current_user.id
  @reply.consultation_id = params[:consultation_id]

  respond_to do |format|
    if @reply.save
      @consultations = Consultation.all # ここで@consultationsを設定
      # app/controllers/replies_controller.rb
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
          turbo_stream.replace('content', partial: 'buttons/menu/consultations_detail', locals: { consultation: @reply.consultation })
        ]
      end
      format.html { redirect_to @reply.consultation, notice: 'Reply was successfully created.' }
    else
      @consultation = Consultation.find(params[:consultation_id]) # ここで@consultationを設定
      format.html { render :new }
      format.json { render json: @reply.errors, status: :unprocessable_entity }
    end
  end
end

private

def reply_params
  params.require(:reply).permit(:content)
end
end


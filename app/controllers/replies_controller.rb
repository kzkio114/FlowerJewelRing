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
      format.turbo_stream { render turbo_stream: turbo_stream.replace('content', partial: 'buttons/menu/consultations_detail', locals: { consultations: @consultations }) }
      format.html { redirect_to @reply, notice: 'Reply was successfully created.' }
    else
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


class RepliesController < ApplicationController
  def create
  @consultation = Consultation.find(params[:consultation_id])
  @reply = @consultation.replies.build(reply_params)
  if @reply.save
    respond_to do |format|
      format.html { redirect_to @consultation, notice: '返信が成功しました。' }
      format.turbo_stream do
        render turbo_stream: turbo_stream.append("replies", partial: "replies/reply", locals: { reply: @reply })
      end
    end
  else
    redirect_to @consultation, alert: '返信の保存に失敗しました。'
  end
end

  private

  def reply_params
    params.require(:reply).permit(:content)
  end
end

# app/controllers/chats_controller.rb
class ChatsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :chat, :destroy]
  before_action :set_chat, only: [:destroy]

  def create
    @chat = current_user.sent_chats.build(chat_params)
    if @chat.save
      ActionCable.server.broadcast 'chat_channel', {
        html: ApplicationController.renderer.render(partial: "chats/message", locals: { chat: @chat }, formats: [:html]),
        sender_id: @chat.sender_id,
        receiver_id: @chat.receiver_id
      }
      head :ok
    else
      logger.debug @chat.errors.full_messages.join(", ")
      render json: @chat.errors, status: :unprocessable_entity
    end
  end

  def chat
    @chats = Chat.all
    @chat = Chat.new
    @receiver_id = 65 # 固定の受信者IDを設定する場合
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/chat_response", locals: { chats: @chats, receiver_id: @receiver_id })
        ]
      end
      format.html
    end
  end

  def destroy
    if @chat.destroy
      head :ok
    else
      render json: @chat.errors, status: :unprocessable_entity
    end
  end

  private

  def chat_params
    params.require(:chat).permit(:receiver_id, :message)
  end

  def set_chat
    @chat = Chat.find(params[:id])
  end
end

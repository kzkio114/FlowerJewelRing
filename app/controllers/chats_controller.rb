class ChatsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :chat]

  def create
    @chat = current_user.sent_chats.build(chat_params)
    if @chat.save
      ActionCable.server.broadcast 'chat_channel', { message: @chat.message, sender_id: @chat.sender_id, receiver_id: @chat.receiver_id }
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

  private

  def chat_params
    params.require(:chat).permit(:receiver_id, :message)
  end
end
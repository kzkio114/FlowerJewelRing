# app/controllers/chats_controller.rb
class ChatsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :chat, :destroy]
  before_action :set_chat, only: [:destroy]

  def create
    @chat = current_user.sent_chats.build(chat_params)
    if @chat.save
      ActionCable.server.broadcast 'chat_channel', {
        action: 'create',
        message: render_to_string(partial: 'chats/message', locals: { chat: @chat }, formats: [:html]),
        success: true
      }
      render turbo_stream: turbo_stream.append('messages', partial: 'chats/message', locals: { chat: @chat })
    else
      logger.debug @chat.errors.full_messages.join(", ")
      render json: @chat.errors, status: :unprocessable_entity
    end
  end

  def chat
    @chats = Chat.all
    @chat = Chat.new
    @receiver_id = params[:receiver_id] # 受信者IDを動的に設定
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
    chat_id = @chat.id
    if @chat.destroy
      ActionCable.server.broadcast 'chat_channel', {
        action: 'destroy',
        chat_id: chat_id
      }
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

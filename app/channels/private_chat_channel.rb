class PrivateChatChannel < ApplicationCable::Channel
  def subscribed
    # セキュリティのために、チャットルームごとにストリームを作成
    if current_user && params[:chat_id]
      @chat = Chat.find(params[:chat.jpg])
      stream_for @chat if @chat.participants.include?(current_user)
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    @chat = Chat.find(data['chat_id'])
    return unless @chat.participants.include?(current_user)

    message = @chat.messages.create!(sender_id: current_user.id, message: data['message'])
    
    # 送信者と受信者にそれぞれブロードキャスト
    PrivateChatChannel.broadcast_to(@chat, {
      message: render_message(message),
      chat_id: @chat.id,
      success: message.persisted?
    })
  end

  private

  def render_message(message)
    ApplicationController.renderer.render(partial: 'chats/message', locals: { chat: message })
  end
end

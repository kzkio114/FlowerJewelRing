class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    message = Chat.create!(sender_id: current_user.id, receiver_id: data['receiver_id'], message: data['message'])

    # 送信者と受信者にブロードキャスト
    ChatChannel.broadcast_to(message.receiver, {
      message: render_message(message),
      success: message.persisted? # メッセージが正常に作成されたことを示すフラグ
    })

    ChatChannel.broadcast_to(message.sender, {
      message: render_message(message),
      success: message.persisted? # メッセージが正常に作成されたことを示すフラグ
    })
  end

  private

  def render_message(message)
    ApplicationController.renderer.render(partial: 'chats/message', locals: { chat: message })
  end
end

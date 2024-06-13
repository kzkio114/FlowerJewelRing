class PrivateChatChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    receiver = User.find(data['receiver_id'])
    message = Chat.create!(sender_id: current_user.id, receiver_id: receiver.id, message: data['message'])

    # 送信者と受信者にそれぞれブロードキャスト
    PrivateChatChannel.broadcast_to(receiver, {
      action: 'create',
      message: render_message(message),
      chat: message,
      success: message.persisted?
    })

    PrivateChatChannel.broadcast_to(current_user, {
      action: 'create',
      message: render_message(message),
      chat: message,
      success: message.persisted?
    })
  end

  private

  def render_message(message)
    ApplicationController.renderer.render(partial: 'private_chats/chat_message', locals: { chat: message })
  end
end

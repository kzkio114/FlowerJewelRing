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
      action: 'create',
      message: render_message(message, false), # 受信者には削除ボタンを表示しない
      chat_id: message.id,
      success: message.persisted?
    })

    ChatChannel.broadcast_to(message.sender, {
      action: 'create',
      message: render_message(message, true), # 送信者には削除ボタンを表示
      chat_id: message.id,
      success: message.persisted?
    })
  end

  def delete_message(data)
    message = Chat.find_by(id: data['chat_id'], sender_id: current_user.id)
    return unless message

    message.destroy!

    # 送信者と受信者にブロードキャスト
    ChatChannel.broadcast_to(message.receiver, {
      action: 'destroy',
      chat_id: message.id
    })

    ChatChannel.broadcast_to(message.sender, {
      action: 'destroy',
      chat_id: message.id
    })
  end

  private

  def render_message(message, show_delete_button)
    ApplicationController.renderer.render(partial: 'chats/message', locals: { chat: message, show_delete_button: show_delete_button })
  end
end

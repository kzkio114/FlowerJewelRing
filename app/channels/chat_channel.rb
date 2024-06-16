class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    message = Chat.create!(sender_id: current_user.id, receiver_id: data['receiver_id'], message: data['message'])
    render_and_broadcast_message(message)
  rescue => e
    logger.error "Failed to send message: #{e.message}"
    # 必要に応じて、フロントエンドにエラーメッセージを送信する
  end

  def delete_message(data)
    message = Chat.find_by(id: data['chat_id'], sender_id: current_user.id)
    return unless message

    message.destroy!
    broadcast_delete_message(message)
  rescue => e
    logger.error "Failed to delete message: #{e.message}"
    # 必要に応じて、フロントエンドにエラーメッセージを送信する
  end

  private

  def render_message(message, show_delete_button)
    ApplicationController.renderer.render(partial: 'chats/message', locals: { chat: message, show_delete_button: show_delete_button })
  rescue => e
    logger.error "Failed to render message: #{e.message}"
    nil
  end

  def render_and_broadcast_message(message)
    receiver_message_html = render_message(message, false)
    sender_message_html = render_message(message, true)

    if receiver_message_html && sender_message_html
      ChatChannel.broadcast_to(message.receiver, {
        action: 'create',
        message: receiver_message_html, # 受信者には削除ボタンを表示しない
        chat_id: message.id,
        success: message.persisted?
      })

      ChatChannel.broadcast_to(message.sender, {
        action: 'create',
        message: sender_message_html, # 送信者には削除ボタンを表示
        chat_id: message.id,
        success: message.persisted?
      })
    else
      logger.error "Failed to broadcast message: message rendering returned nil"
    end
  end

  def broadcast_delete_message(message)
    ChatChannel.broadcast_to(message.receiver, {
      action: 'destroy',
      chat_id: message.id
    })

    ChatChannel.broadcast_to(message.sender, {
      action: 'destroy',
      chat_id: message.id
    })
  end
end

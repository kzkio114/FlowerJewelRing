class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    message = Chat.create!(sender_id: current_user.id, receiver_id: data['receiver_id'], message: data['message'])
    
    ActionCable.server.broadcast("chat_channel", {
      message: render_message(message),
      success: message.persisted? # メッセージが正常に作成されたことを示すフラグ
    })
  end

  private

  def render_message(message)
    ApplicationController.renderer.render(partial: 'chats/message', locals: { chat: message })
  end
end

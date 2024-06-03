# app/channels/chat_channel.rb
class ChatChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    # メッセージの作成と保存
    message = Chat.create!(sender_id: current_user.id, receiver_id: data['receiver_id'], message: data['message'])
    
    # Turbo Streamsを使用してフロントエンドにメッセージを送信
    ActionCable.server.broadcast("chat_channel", {
      html: ApplicationController.renderer.render(partial: "chats/message", locals: { chat: message }),
      sender_id: message.sender_id,
      receiver_id: message.receiver_id
    })
  end
end

class GroupChatChannel < ApplicationCable::Channel
  def subscribed
    stream_for GroupChat.find(params[:id])
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    group_chat = GroupChat.find(data['group_chat_id'])
    message = group_chat.group_chat_messages.create!(user: current_user, message: data['message'])

    GroupChatChannel.broadcast_to(group_chat, {
      message: render_message(message),
      success: message.persisted?
    })
  end

  private

  def render_message(message)
    ApplicationController.renderer.render(partial: 'group_chat_messages/message', locals: { message: message })
  end
end

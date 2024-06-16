class GroupChatChannel < ApplicationCable::Channel
  def subscribed
    group_chat = GroupChat.find(params[:group_chat_id])
    stream_for group_chat
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    message = GroupChatMessage.create!(group_chat_id: data['group_chat_id'], user: current_user, message: data['message'])
    GroupChatChannel.broadcast_to(message.group_chat, {
      action: 'create',
      message_html: render_message(message),
      message_id: message.id
    })
  end

  def delete_message(data)
    message = GroupChatMessage.find(data['message_id'])
    if message.destroy
      GroupChatChannel.broadcast_to(message.group_chat, {
        action: 'destroy',
        message_id: data['message_id']
      })
    end
  end

  private

  def render_message(message)
    ApplicationController.renderer.render(partial: 'group_chat_messages/message', locals: { message: message })
  end
end

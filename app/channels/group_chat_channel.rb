class GroupChatChannel < ApplicationCable::Channel
  def subscribed
    group_chat = GroupChat.find(params[:group_chat_id])
    stream_for group_chat
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    group_chat = GroupChat.find(data['group_chat_id'])
    message = group_chat.group_chat_messages.create!(user: current_user, message: data['message'])

    GroupChatChannel.broadcast_to(group_chat, {
      action: 'create',
      message: render_message(message),
      user_id: message.user.id,
      group_chat_id: group_chat.id
    })
  end

  private

  def render_message(message)
    ApplicationController.renderer.render(partial: 'group_chat_messages/message', locals: { message: message, show_delete_button: message.user == current_user })
  end
end

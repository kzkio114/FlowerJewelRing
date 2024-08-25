class GroupChatChannel < ApplicationCable::Channel
  def subscribed
    group_chat = GroupChat.find(params[:group_chat_id])
    stream_for group_chat
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def speak(data)
    message = GroupChatMessage.new(group_chat_id: data['group_chat_id'], user: current_user, message: data['message'])
  
    if message.save
      render_and_broadcast_message(message)
    else
      GroupChatChannel.broadcast_to(current_user, {
        action: 'error',
        errors: message.errors.full_messages
      })
    end
  rescue => e
    logger.error "Failed to send message: #{e.message}"
    GroupChatChannel.broadcast_to(current_user, {
      action: 'error',
      errors: ['Failed to send message due to an unexpected error.']
    })
  end

  def delete_message(data)
    message = GroupChatMessage.find_by(id: data['message_id'], user_id: current_user.id)
    return unless message

    message.destroy!
    broadcast_delete_message(message)
  rescue => e
    logger.error "Failed to delete message: #{e.message}"
  end

  private

  def render_message(message, show_delete_button)
    ApplicationController.renderer.render(partial: 'group_chat_messages/message', locals: { message: message, show_delete_button: show_delete_button })
  rescue => e
    logger.error "Failed to render message: #{e.message}"
    nil
  end

  def render_and_broadcast_message(message)
    message_html = render_message(message, true)

    if message_html
      GroupChatChannel.broadcast_to(message.group_chat, {
        action: 'create',
        message_html: message_html,
        message_id: message.id,
        success: message.persisted?
      })
    else
      logger.error "Failed to broadcast message: message rendering returned nil"
    end
  end

  def broadcast_delete_message(message)
    GroupChatChannel.broadcast_to(message.group_chat, {
      action: 'destroy',
      message_id: message.id
    })
  end
end

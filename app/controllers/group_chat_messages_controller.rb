class GroupChatMessagesController < ApplicationController
  before_action :set_group_chat

  def create
    @group_chat_message = @group_chat.group_chat_messages.build(group_chat_message_params)
    @group_chat_message.user = current_user

    respond_to do |format|
      if @group_chat_message.save
        show_delete_button = @group_chat_message.user == current_user
        GroupChatChannel.broadcast_to(@group_chat, {
          action: 'create',
          message_html: render_to_string(partial: 'group_chat_messages/message', locals: { message: @group_chat_message, show_delete_button: show_delete_button }, formats: [:html]),
          message_id: @group_chat_message.id,
          success: true
        })
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.append('messages', partial: 'group_chat_messages/message', locals: { message: @group_chat_message, show_delete_button: show_delete_button }),
            turbo_stream.replace('new_group_chat_message', partial: 'group_chat_messages/form', locals: { group_chat: @group_chat, group_chat_message: GroupChatMessage.new })
          ]
        }
        format.html { redirect_to group_chat_path(@group_chat) }
      else
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace('new_group_chat_message', partial: 'group_chat_messages/form', locals: { group_chat_message: @group_chat_message })
        }
        format.html { render 'group_chats/show' }
      end
    end
  end

  private

  def set_group_chat
    @group_chat = GroupChat.find(params[:group_chat_id])
  end

  def group_chat_message_params
    params.require(:group_chat_message).permit(:message)
  end
end

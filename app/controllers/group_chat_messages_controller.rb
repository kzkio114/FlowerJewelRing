class GroupChatMessagesController < ApplicationController
  before_action :set_group_chat

  def create
    @group_chat_message = @group_chat.group_chat_messages.build(group_chat_message_params)
    @group_chat_message.user = current_user

    if @group_chat_message.save
      GroupChatChannel.broadcast_to(@group_chat, {
        action: 'create',
        message_html: render_to_string(partial: 'group_chat_messages/message', locals: { message: @group_chat_message, show_delete_button: true }, formats: [:html]),
        message_id: @group_chat_message.id,
        success: true
      })
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append('messages', partial: 'group_chat_messages/message', locals: { message: @group_chat_message, show_delete_button: true }) }
      end
    else
      render :new
    end
  end

  def destroy
    @group_chat_message = @group_chat.group_chat_messages.find(params[:id])
    @group_chat_message.destroy

    GroupChatChannel.broadcast_to(@group_chat, {
      action: 'destroy',
      message_id: @group_chat_message.id
    })

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("message_#{@group_chat_message.id}") }
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

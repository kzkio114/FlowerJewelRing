class GroupChatMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group_chat

  def create
    @group_chat_message = @group_chat.group_chat_messages.build(group_chat_message_params)
    @group_chat_message.user = current_user
    if @group_chat_message.save
      ActionCable.server.broadcast "group_chat_#{@group_chat.id}", {
        message: render_message(@group_chat_message),
        user_id: @group_chat_message.user.id,
        group_chat_id: @group_chat.id
      }
      head :ok
    else
      render json: @group_chat_message.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @group_chat_message = @group_chat.group_chat_messages.find(params[:id])
    @group_chat_message.destroy
    head :ok
  end

  private

  def group_chat_message_params
    params.require(:group_chat_message).permit(:message)
  end

  def set_group_chat
    @group_chat = GroupChat.find(params[:group_chat_id])
  end

  def render_message(message)
    ApplicationController.renderer.render(partial: 'group_chat_messages/message', locals: { message: message })
  end
end

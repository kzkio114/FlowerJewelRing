class GroupChatMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group_chat
  before_action :set_group_chat_message, only: [:destroy]

  def create
    @group_chat_message = @group_chat.group_chat_messages.build(group_chat_message_params)
    @group_chat_message.user = current_user
    if @group_chat_message.save
      ActionCable.server.broadcast "group_chat_#{@group_chat.id}", {
        action: 'create',
        message: render_message(@group_chat_message, true),
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
    if @group_chat_message.user == current_user
      @group_chat_message.destroy
      ActionCable.server.broadcast "group_chat_#{@group_chat.id}", {
        action: 'destroy',
        message_id: @group_chat_message.id
      }
      head :ok
    else
      head :forbidden
    end
  end

  private

  def group_chat_message_params
    params.require(:group_chat_message).permit(:message)
  end

  def set_group_chat
    @group_chat = GroupChat.find(params[:group_chat_id])
  end

  def set_group_chat_message
    @group_chat_message = @group_chat.group_chat_messages.find(params[:id])
  end

  def render_message(message, show_delete_button)
    ApplicationController.renderer.render(partial: 'group_chat_messages/message', locals: { message: message, show_delete_button: show_delete_button })
  end
end

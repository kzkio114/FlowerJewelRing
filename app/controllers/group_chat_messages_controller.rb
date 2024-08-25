class GroupChatMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group_chat
  before_action :set_group_chat_message, only: [:destroy]
  before_action :ensure_owner, only: [:destroy]

  def create
    @group_chat_message = current_user.group_chat_messages.build(group_chat_message_params.merge(group_chat: @group_chat))

    if @group_chat_message.save
      message_html = render_to_string(
        partial: 'group_chat_messages/message', 
        locals: { message: @group_chat_message, show_delete_button: true }, 
        formats: [:html]
      )
    
      GroupChatChannel.broadcast_to(@group_chat, {
        action: 'create',
        message_html: message_html,
        message_id: @group_chat_message.id,
        success: true
      })
      
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append('messages', message_html),
            turbo_stream.replace('new_group_chat_message', partial: 'group_chat_messages/form', locals: { group_chat: @group_chat, group_chat_message: GroupChatMessage.new })
          ]
        end
        format.html { redirect_to group_chat_path(@group_chat) }
      end
    else
      render json: @group_chat_message.errors, status: :unprocessable_entity
    end
  rescue => e
    logger.error "Failed to create message: #{e.message}"
    render json: { error: 'Failed to create message' }, status: :unprocessable_entity
  end

  def destroy
    if @group_chat_message.destroy
      GroupChatChannel.broadcast_to(@group_chat, {
        action: 'destroy',
        message_id: @group_chat_message.id
      })
      
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove("message_#{@group_chat_message.id}") }
        format.html { redirect_to group_chat_path(@group_chat) }
      end
    else
      render json: @group_chat_message.errors, status: :unprocessable_entity
    end
  rescue => e
    logger.error "Failed to destroy message: #{e.message}"
    render json: { error: 'Failed to destroy message' }, status: :unprocessable_entity
  end

  private

  def set_group_chat
    @group_chat = GroupChat.find(params[:group_chat_id])
  end

  def set_group_chat_message
    @group_chat_message = @group_chat.group_chat_messages.find(params[:id])
  end

  def group_chat_message_params
    params.require(:group_chat_message).permit(:message)
  end

  def ensure_owner
    unless @group_chat_message.user == current_user
      render json: { error: "You are not authorized to delete this message." }, status: :forbidden
    end
  end
end

class GroupChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group_chat, only: [:group_chat, :edit, :update, :destroy]

  def group_chat
    @group_chat_messages = @group_chat.group_chat_messages.includes(:user)
    @group_chat_message = GroupChatMessage.new
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("content", partial: "group_chats/chat_response", locals: { group_chat: @group_chat, group_chat_messages: @group_chat_messages, group_chat_message: @group_chat_message, show_delete_button: true })
      end
      format.html
    end
  end

  def edit
  end

  def update
    if @group_chat.update(group_chat_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("edit_group_chat", ""),
            turbo_stream.replace("content", partial: "group_chats/chat_response", locals: { group_chat: @group_chat, group_chat_messages: @group_chat_messages, group_chat_message: @group_chat_message, show_delete_button: true })
          ]
        end
        format.html { redirect_to group_chat_path(@group_chat), notice: 'グループチャットが更新されました' }
      end
    else
      render :edit
    end
  end

  def destroy
    @group_chat.destroy
    redirect_to root_path, notice: 'グループチャットが削除されました'
  end

  private

  def group_chat_params
    params.require(:group_chat).permit(:title)
  end

  def set_group_chat
    @group_chat = GroupChat.find(params[:id])
  end
end

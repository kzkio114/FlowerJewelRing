class GroupChatMessagesController < ApplicationController
  before_action :set_group_chat

  def create
    @group_chat_message = @group_chat.group_chat_messages.build(group_chat_message_params)
    @group_chat_message.user = current_user

    if @group_chat_message.save
      message_html = render_to_string(
        partial: 'group_chat_messages/message', 
        locals: { message: @group_chat_message, show_delete_button: @group_chat_message.user == current_user }, 
        formats: [:html]
      )
    
      GroupChatChannel.broadcast_to(@group_chat, {
        action: 'create',
        message_html: message_html,
        message_id: @group_chat_message.id,
        success: true
      })
    
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.append('messages', partial: 'group_chat_messages/message', locals: { message: @group_chat_message, show_delete_button: @group_chat_message.user == current_user }),
            turbo_stream.replace('new_group_chat_message', partial: 'group_chat_messages/form', locals: { group_chat: @group_chat, group_chat_message: GroupChatMessage.new }) # フォームをクリアする
          ]
        }
        format.html { redirect_to group_chat_path(@group_chat) }
      end
    else
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace('new_group_chat_message', partial: 'group_chat_messages/form', locals: { group_chat_message: @group_chat_message })
        }
        format.html { render 'group_chats/group_chat' }
      end
    end
  end

  def destroy
    @group_chat_message = @group_chat.group_chat_messages.find(params[:id])
  
    # メッセージの作成者のみが削除できるようにする
    if @group_chat_message.user == current_user
      @group_chat_message.destroy
  
      GroupChatChannel.broadcast_to(@group_chat, {
        action: 'destroy',
        message_id: @group_chat_message.id
      })
  
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.remove("message_#{@group_chat_message.id}") }
        format.html { redirect_to group_chat_path(@group_chat) }
      end
    else
      # 権限がない場合の処理
      respond_to do |format|
        format.html { redirect_to group_chat_path(@group_chat), alert: "ダメだよ！" }
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

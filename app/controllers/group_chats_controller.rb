class GroupChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group_chat, only: [:group_chat, :edit, :update, :destroy]

  def index
    @group_chats = GroupChat.all
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "group_chats/index", locals: { group_chats: @group_chats }),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user })
        ]
      end
      format.html { render :index, locals: { group_chats: @group_chats } }
    end
  end

  def group_chat
    @group_chat_messages = @group_chat.group_chat_messages.includes(:user)
    @group_chat_message = GroupChatMessage.new
    @group_chat_members = @group_chat.group_chat_members

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "group_chats/group_chat", locals: { group_chat: @group_chat }),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user })
        ]
      end
      format.html
    end
  end

  def new
    @group_chat = GroupChat.new
  end

  def create
    @group_chat = GroupChat.new(group_chat_params)
    if @group_chat.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.append('group_chat_list', partial: 'group_chats/group_chat', locals: { group_chat: @group_chat }) }
        format.html { redirect_to @group_chat, notice: 'グループチャットが作成されました' }
      end
    else
      render :new
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("edit_group_chat", partial: "group_chats/edit_group_chat", locals: { group_chat: @group_chat })
      end
      format.html { render :edit }
    end
  end

  def update
    if @group_chat.update(group_chat_params)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace('group_chat_content', partial: 'group_chats/group_chat_response', locals: { group_chat: @group_chat }) }
        format.html { redirect_to @group_chat, notice: 'グループチャットが更新されました' }
      end
    else
      render :edit
    end
  end

  def destroy
    @group_chat.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove("group_chat_#{params[:id]}") }
      format.html { redirect_to group_chats_url, notice: 'グループチャットが削除されました' }
    end
  end

  private

  def set_group_chat
    @group_chat = GroupChat.find(params[:id])
  end

  def group_chat_params
    params.require(:group_chat).permit(:title)
  end
end

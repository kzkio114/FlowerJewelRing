class GroupChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group_chat, only: [:group_chat, :edit, :update, :destroy]

  def group_chat_list
    @group_chats = GroupChat.all
    @group_chat = GroupChat.new
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "group_chats/group_chat_list", locals: { group_chats: @group_chats, group_chat: @group_chat }),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user })
        ]
      end
    end
  end

  def group_chat
    @group_chat_messages = @group_chat.group_chat_messages.includes(:user)
    @group_chat_message = GroupChatMessage.new
    @group_chat_members = @group_chat.group_chat_members

    # Public グループチャットの場合、ユーザーを自動的にメンバーとして追加
    if @group_chat.group_chat_members.exists?(role: 'free') && !@group_chat.member?(current_user)
      @group_chat.group_chat_members.create(user: current_user, role: :free)
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "group_chats/group_chat", locals: { group_chat: @group_chat }),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user })
        ]
      end
    end
  end

  def new
    @group_chat = GroupChat.new
  end

  def create
    @group_chat = GroupChat.new(group_chat_params.except(:role))
    @group_chats = GroupChat.all
    if @group_chat.save
      role = group_chat_params[:role] == 'free' ? :free : :admin
      GroupChatMember.create(group_chat: @group_chat, user: current_user, role: role)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("content", partial: "group_chats/group_chat", locals: { group_chat: @group_chat }),
            turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user })
          ]
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("content", partial: "group_chats/group_chat_list", locals: { group_chats: @group_chats, group_chat: @group_chat })
        end
      end
    end
  end

  def edit
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("edit_group_chat", partial: "group_chats/edit_group_chat", locals: { group_chat: @group_chat })
      end
      format.html do
        render partial: "group_chats/edit_group_chat", locals: { group_chat: @group_chat }
      end
    end
  end

  def update
    if @group_chat.update(group_chat_params)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace('group_chat', partial: 'group_chats/group_chat', locals: { group_chat: @group_chat }) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("edit_group_chat", partial: "group_chats/edit_group_chat", locals: { group_chat: @group_chat }) }
      end
    end
  end

  def destroy
    @group_chat = GroupChat.find(params[:id])
    @group_chat.destroy
    @group_chats = GroupChat.all
    @new_group_chat = GroupChat.new # 新しいグループチャットオブジェクトを作成
  
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("content", partial: "group_chats/group_chat_list", locals: { group_chats: @group_chats, group_chat: @new_group_chat })
      end
      format.html { redirect_to group_chats_path, notice: 'グループチャットが削除されました。' }
    end
  end


  private

  def set_group_chat
    @group_chat = GroupChat.find(params[:id])
  end

  def group_chat_params
    params.require(:group_chat).permit(:title, :role)
  end
end

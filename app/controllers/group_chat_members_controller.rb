class GroupChatMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group_chat

  def new
    @group_chat_member = GroupChatMember.new
  end

  def create
    @group_chat_member = @group_chat.group_chat_members.build(group_chat_member_params)
    if @group_chat_member.save
      redirect_to custom_group_chat_group_chat_path(@group_chat), notice: 'メンバーが追加されました'
    else
      render :new
    end
  end

  def destroy
    @group_chat_member = @group_chat.group_chat_members.find(params[:id])
    @group_chat_member.destroy
    redirect_to custom_group_chat_group_chat_path(@group_chat), notice: 'メンバーが削除されました'
  end

  private

  def set_group_chat
    @group_chat = GroupChat.find(params[:group_chat_id])
  end

  def group_chat_member_params
    params.require(:group_chat_member).permit(:user_id, :role)
  end
end

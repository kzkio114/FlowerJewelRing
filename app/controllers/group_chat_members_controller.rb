class GroupChatMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group_chat
  before_action :set_group_chat_member, only: [:destroy]

  def new
    @group_chat_member = GroupChatMember.new
    @users = User.where.not(id: @group_chat.users.pluck(:id))
  end

  def create
    @group_chat_member = @group_chat.group_chat_members.build(group_chat_member_params)
    @users = User.where.not(id: @group_chat.users.pluck(:id))

    if @group_chat_member.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append("group_chat_members", partial: "group_chat_members/member", locals: { group_chat_member: @group_chat_member }),
            turbo_stream.replace("new_group_chat_member", partial: "group_chat_members/form", locals: { group_chat: @group_chat, group_chat_member: GroupChatMember.new, users: @users })
          ]
        end
        format.html { redirect_to group_chat_path(@group_chat), notice: 'メンバーが追加されました。' }
      end
    else
      render :new
    end
  end

  def destroy
    @group_chat_member.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@group_chat_member) }
      format.html { redirect_to group_chat_path(@group_chat), notice: 'メンバーが削除されました。' }
    end
  end

  private

  def set_group_chat
    @group_chat = GroupChat.find(params[:group_chat_id])
  end

  def set_group_chat_member
    @group_chat_member = @group_chat.group_chat_members.find(params[:id])
  end

  def group_chat_member_params
    params.require(:group_chat_member).permit(:user_id, :role)
  end
end

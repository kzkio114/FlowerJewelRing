class GroupChatsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :group_chat, :destroy]
  before_action :set_group_chat, only: [:group_chat, :destroy]

  def new
    @group_chat = GroupChat.new
  end

  def create
    @group_chat = GroupChat.new(group_chat_params)
    if @group_chat.save
      redirect_to custom_group_chat_group_chat_path(@group_chat)
    else
      render :new
    end
  end

  def group_chat
    @group_chat = GroupChat.first_or_create(title: "Default Group Chat") # グループチャットが存在しない場合、新規作成
    @group_chat_messages = @group_chat.group_chat_messages.includes(:user)
    @group_chat_message = GroupChatMessage.new
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "group_chats/chat_response", locals: { group_chat: @group_chat, group_chat_messages: @group_chat_messages, group_chat_message: @group_chat_message })
        ]
      end
      format.html
    end
  end

  def destroy
    if @group_chat.destroy
      head :ok
    else
      render json: @group_chat.errors, status: :unprocessable_entity
    end
  end

  private

  def group_chat_params
    params.require(:group_chat).permit(:title)
  end

  def set_group_chat
    @group_chat = GroupChat.find(params[:id])
  end
end

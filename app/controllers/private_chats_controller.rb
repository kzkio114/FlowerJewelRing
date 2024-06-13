class PrivateChatsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :private_chat, :destroy]
  before_action :set_chat, only: [:destroy]

  def create
    @private_chat = current_user.sent_chats.build(chat_params)
    if @private_chat.save
      PrivateChatChannel.broadcast_to(@private_chat.receiver, {
        action: 'create',
        message: render_to_string(partial: 'private_chats/chat_message', locals: { chat: @private_chat }, formats: [:html]),
        chat: @private_chat,
        success: true
      })
      PrivateChatChannel.broadcast_to(current_user, {
        action: 'create',
        message: render_to_string(partial: 'private_chats/chat_message', locals: { chat: @private_chat }, formats: [:html]),
        chat: @private_chat,
        success: true
      })
      render turbo_stream: turbo_stream.append('messages', partial: 'private_chats/chat_message', locals: { chat: @private_chat })
    else
      render json: @private_chat.errors, status: :unprocessable_entity
    end
  end

  def private_chat
    @private_chat = Chat.new
    @receiver_id = params[:receiver_id]
    if @receiver_id.present?
      @selected_user = User.find(@receiver_id)
      @private_chats = Chat.where(sender: current_user, receiver: @selected_user)
                   .or(Chat.where(sender: @selected_user, receiver: current_user))
    else
      @private_chats = []
    end
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("content", partial: "private_chats/chat_form", locals: { chats: @private_chats, receiver_id: @receiver_id, selected_user: @selected_user })
      end
      format.html
    end
  end

  def destroy
    chat_id = @private_chat.id
    if @private_chat.destroy
      PrivateChatChannel.broadcast_to(current_user, {
        action: 'destroy',
        chat_id: chat_id
      })
      PrivateChatChannel.broadcast_to(@private_chat.receiver, {
        action: 'destroy',
        chat_id: chat_id
      })
      head :ok
    else
      render json: @private_chat.errors, status: :unprocessable_entity
    end
  end

  private

  def chat_params
    params.require(:chat).permit(:receiver_id, :message)
  end

  def set_chat
    @private_chat = Chat.find(params[:id])
  end
end

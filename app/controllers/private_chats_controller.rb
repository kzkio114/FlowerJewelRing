class PrivateChatsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :private_chat, :destroy]
  before_action :set_chat, only: [:destroy]

  def create
    @chat = current_user.sent_chats.build(chat_params)
    if @chat.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append('messages', partial: 'chats/chat_message', locals: { chat: @chat })
          ]
        end
        format.html { redirect_to private_chats_path(receiver_id: @chat.receiver_id) }
      end
    else
      logger.debug @chat.errors.full_messages.join(", ")
      render json: @chat.errors, status: :unprocessable_entity
    end
  end

  def private_chat
    @receiver_id = params[:receiver_id]
    if @receiver_id.present?
      @selected_user = User.find(@receiver_id)
      @chats = Chat.where(sender: current_user, receiver: @selected_user)
                   .or(Chat.where(sender: @selected_user, receiver: current_user))
    else
      @chats = []
    end
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "private_chats/chat_form", locals: { chats: @chats, receiver_id: @receiver_id, selected_user: @selected_user }),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user })
        ]
      end
      format.html
    end
  end

  def destroy
    chat_id = @chat.id
    if @chat.destroy
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove("chat_#{chat_id}")
        end
        format.html { redirect_to private_chats_path }
      end
    else
      render json: @chat.errors, status: :unprocessable_entity
    end
  end

  private

  def chat_params
    params.require(:chat).permit(:receiver_id, :message)
  end

  def set_chat
    @chat = Chat.find(params[:id])
  end
end

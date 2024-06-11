class PrivateChatsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :private_chat, :destroy]
  before_action :set_chat, only: [:destroy]

  def create
    @private_chat = current_user.sent_chats.build(chat_params)
    if @private_chat.save
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.append('messages', partial: 'private_chats/chat_message', locals: { chat: @private_chat })
          ]
        end
        format.html { redirect_to private_chats_path(receiver_id: @private_chat.receiver_id) }
      end
    else
      logger.debug @private_chat.errors.full_messages.join(", ")
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
        render turbo_stream: [
          turbo_stream.replace("content", partial: "private_chats/chat_form", locals: { chats: @private_chats, receiver_id: @receiver_id, selected_user: @selected_user }),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user })
        ]
      end
      format.html
    end
  end

  def destroy
    chat_id = @private_chat.id
    if @private_chat.destroy
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove("chat_#{chat_id}")
        end
        format.html { redirect_to private_chats_path }
      end
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

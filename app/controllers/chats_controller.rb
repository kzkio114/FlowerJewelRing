class ChatsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :chat, :destroy]
  before_action :set_chat, only: [:destroy]
  before_action :ensure_sender, only: [:destroy]

  def create
    @chat = current_user.sent_chats.build(chat_params)
    if @chat.save
      message_html = render_to_string(partial: 'chats/message', locals: { chat: @chat, show_delete_button: false }, formats: [:html])
      ChatChannel.broadcast_to(@chat.receiver, {
        action: 'create',
        message: message_html,
        chat_id: @chat.id,
        success: true
      })
      
      message_html_with_delete = render_to_string(partial: 'chats/message', locals: { chat: @chat, show_delete_button: true }, formats: [:html])
      ChatChannel.broadcast_to(current_user, {
        action: 'create',
        message: message_html_with_delete,
        chat_id: @chat.id,
        success: true
      })
      render turbo_stream: turbo_stream.append('messages', partial: 'chats/message', locals: { chat: @chat, show_delete_button: true })
    else
      logger.debug @chat.errors.full_messages.join(", ")
      render json: @chat.errors, status: :unprocessable_entity
    end
  rescue => e
    logger.error "Failed to create chat: #{e.message}"
    render json: { error: 'Failed to create chat' }, status: :unprocessable_entity
  end

  def chat
    @receiver_id = params[:receiver_id]
    @selected_user = User.find(@receiver_id) if @receiver_id.present?

    if @selected_user
      @chats = Chat.where(sender: current_user, receiver: @selected_user)
                   .or(Chat.where(sender: @selected_user, receiver: current_user))
    else
      @chats = []
    end

    @chat = Chat.new

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "chats/chat_response", locals: { chats: @chats, receiver_id: @receiver_id, selected_user: @selected_user }),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user })
        ]
      end
      format.html
    end
  rescue => e
    logger.error "Failed to load chat: #{e.message}"
    render json: { error: 'Failed to load chat' }, status: :unprocessable_entity
  end

  def destroy
    chat_id = @chat.id
    if @chat.destroy
      ChatChannel.broadcast_to(current_user, {
        action: 'destroy',
        chat_id: chat_id
      })
      ChatChannel.broadcast_to(@chat.receiver, {
        action: 'destroy',
        chat_id: chat_id
      })
      head :ok
    else
      render json: @chat.errors, status: :unprocessable_entity
    end
  rescue => e
    logger.error "Failed to destroy chat: #{e.message}"
    render json: { error: 'Failed to destroy chat' }, status: :unprocessable_entity
  end

  private

  def chat_params
    params.require(:chat).permit(:receiver_id, :message)
  end

  def set_chat
    @chat = Chat.find(params[:id])
  end

  def ensure_sender
    unless @chat.sender == current_user
      render json: { error: "You are not authorized to delete this message." }, status: :forbidden
    end
  end
end

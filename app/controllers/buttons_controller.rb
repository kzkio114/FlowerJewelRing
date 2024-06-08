class ButtonsController < ApplicationController

  def enter_app
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("response_area", partial: "buttons/enter_app_response")
        ]
      end
    end
  end

  def login
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("response_area", partial: "buttons/login_response"),
          turbo_stream.replace("login_button", partial: "buttons/without_login_button"),
          turbo_stream.replace("content", partial: "buttons/menu/trial_login_response")
        ]
      end
    end
  end

  def menu
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
        turbo_stream.replace("menu", partial: "buttons/menu/menu_buttons"),
        turbo_stream.replace("content", partial: "buttons/response"),
        turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user })
        ]
      end
    end
  end

  def close_menu
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
        turbo_stream.replace("menu", partial: "buttons/menu/closed_menu"),
        turbo_stream.replace("content", partial: "buttons/response"),
        turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user })
        ]
      end
    end
  end

  def worries
    if params[:category_id]
      @consultations = Consultation.includes(:category).where(category_id: params[:category_id])
    else
      @consultations = Consultation.includes(:category).all
    end

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/worries_response", locals: { consultations: @consultations }),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user })
        ]
      end
    end
  end

  def consultations_category
    if params[:category_id]
      @consultations = Consultation.includes(:category).where(category_id: params[:category_id], completed: true)
    else
      @consultations = Consultation.includes(:category).all
    end
  
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/consultations_category", locals: { consultations: @consultations })
        ]
      end
    end
  end




  def consultations_response
    @consultation = Consultation.find(params[:id])  # idはルーティングで設定された :member から取得
    respond_to do |format|
      format.html { redirect_to @consultation }  # HTML応答が必要な場合
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace('content', partial: 'buttons/menu/consultations_response', locals: { consultation: @consultation })
      end
    end
  rescue ActiveRecord::RecordNotFound
    # コンサルテーションが見つからない場合のエラーハンドリング
    redirect_to consultations_path, alert: "指定された相談が見つかりません。"
  end

  def consultations_destroy
    @consultation = Consultation.find(params[:id])
    @consultation.destroy
  
    @consultations = Consultation.includes(:category).all
  
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/worries_response", locals: { consultations: @consultations })
        ]
      end
    end
  end




  def consultations_detail
    @consultation = Consultation.includes(replies: :user).find(params[:id])
    @consultations = Consultation.includes(:category).all

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/consultations_detail", locals: { consultation: @consultation })
        ]
      end
    end
  end


  def consultations_destroy_reply
    @consultation = Consultation.includes(replies: :user).find(params[:consultation_id])
    @reply = @consultation.replies.find(params[:reply_id])
    @reply.destroy
  
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("reply_#{@reply.id}"),  # ここを修正
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user })
        ]
      end
      format.html { redirect_to @consultation, notice: 'Reply was successfully deleted.' }
    end
  end


  # def consultations_post
  #   @consultations = Consultation.includes(:category).all

  #   respond_to do |format|
  #     format.turbo_stream do
  #       render turbo_stream: [
  #         turbo_stream.replace("content", partial: "buttons/menu/consultations_post", locals: { consultations: @consultations })
  #       ]
  #     end
  #   end
  # end



  def gift_list
    #@gifts = Gift.includes(:gift_category).where(receiver_id: current_user.id)  # ユーザーが受け取ったギフトを取得
    @total_sender_messages_count = GiftHistory.where.not(sender_message: [nil, ""]).count
    
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream:[
          turbo_stream.replace("content", partial: "buttons/menu/gift_list_response", locals: { total_sender_messages_count: @total_sender_messages_count }),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user })
        ]
      end
    end
  end




  



  def gift_all
    @gifts = Gift.includes(:gift_category).all
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/gift_all_response", locals: { gifts: @gifts }),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user })
      ]
        end
    end
  end




  def send_gift_response
    # 自分の相談を取得
    @my_consultations = Consultation.where(user_id: current_user.id)
    
    # 自分の相談に対する返信者のIDを取得
    replier_ids = @my_consultations.joins(:replies).pluck('replies.user_id').uniq
    # 返信者のユーザーオブジェクトを取得
    @reply_users = User.where(id: replier_ids)
    # 全てのギフトを取得
    @gifts = Gift.all

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "content", 
          partial: "buttons/menu/send_gift_response", 
          locals: { gifts: @gifts, reply_users: @reply_users }
        )
      end
    end
  end
  

  # def send_gift
  #   @gift = Gift.find(params[:id])
  #   @gift.giver_id = current_user.id
  #   @gift.receiver_id = params[:receiver_id]  # 送信先のユーザーIDをパラメータから取得
  
  #   if @gift.save
  #     @gifts = Gift.includes(:gift_category).where(receiver_id: current_user.id)  # ユーザーが受け取ったギフトを取得
  #     respond_to do |format|
  #       format.turbo_stream do
  #         render turbo_stream: turbo_stream.replace(
  #           "content", 
  #           partial: "buttons/menu/send_gift_response", 
  #           locals: { gifts: @gifts }
  #         )
  #       end
  #     end
  #   else
  #     # ギフトの保存に失敗した場合の処理を書く
  #   end
  # end

  def user
    @users = User.all
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/user_response"),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user })
        ]
      end
    end
  end

  def user_show
    @user = User.find(params[:id])
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/user_show_response")
        ]
      end
    end
  end

  # def user_profile
  #   @users = User.all
  #   respond_to do |format|
  #     format.turbo_stream do
  #       render turbo_stream: [
  #         turbo_stream.replace("content", partial: "buttons/menu/user_profile")
  #       ]
  #     end
  #   end
  # end

  # def chat
  #   @chats = Chat.all
  #   @chat = Chat.new
  #   respond_to do |format|
  #     format.turbo_stream do
  #       render turbo_stream: [
  #         turbo_stream.replace("content", partial: "buttons/menu/chat_response", locals: { chats: @chats })
  #       ]
  #     end
  #   end
  # end

#   def create_chat
#     @chat = Chat.new(chat_params)
#     @chat.sender_id = current_user.id

#     if @chat.save
#       ActionCable.server.broadcast "chat_channel", message: @chat.decrypted_message, sender_id: @chat.sender_id, receiver_id: @chat.receiver_id
#       head :ok
#     else
#       head :unprocessable_entity
#     end
#   end

#   private

#   def chat_params
#     params.require(:chat).permit(:receiver_id, :message)
#   end
end






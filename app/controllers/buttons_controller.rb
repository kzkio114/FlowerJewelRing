class ButtonsController < ApplicationController

  def enter_app
    set_unread_gifts_count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("response_area", partial: "buttons/enter_app_response")
        ]
      end
    end
  end

  def tos
    set_unread_gifts_count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("response_area", partial: "buttons/tos_response")
        ]
      end
    end
  end

  def pp
    set_unread_gifts_count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("response_area", partial: "buttons/pp_response")
        ]
      end
    end
  end

  def login
    set_unread_gifts_count
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
    @group_chats = GroupChat.all
    set_unread_gifts_count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("menu", partial: "buttons/menu/menu_buttons"),
          turbo_stream.replace("content", partial: "buttons/response"),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count })
        ]
      end
    end
  end

  def close_menu
    set_unread_gifts_count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("menu", partial: "buttons/menu/closed_menu"),
          turbo_stream.replace("content", partial: "buttons/response"),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count })
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
    @consultation = Consultation.new
    set_unread_gifts_count

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/worries_response", locals: { consultations: @consultations, consultation: @consultation }),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count })
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
  
    set_unread_gifts_count

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
    set_unread_gifts_count
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
    set_unread_gifts_count
    @consultations = Consultation.includes(:category).all
    @new_consultation = Consultation.new  # 新しいConsultationインスタンスを作成
  
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/worries_response", locals: { consultations: @consultations, consultation: @new_consultation })
        ]
      end
    end
  end

  def consultations_detail
    @consultation = Consultation.includes(replies: :user).find(params[:id])
    @consultations = Consultation.includes(:category).all
    set_unread_gifts_count
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
    set_unread_gifts_count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.remove("reply_#{@reply.id}"),  # ここを修正
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count })
        ]
      end
      format.html { redirect_to @consultation, notice: 'Reply was successfully deleted.' }
    end
  end

  def gift_list
    @total_sender_messages_count = GiftHistory.where.not(sender_message: [nil, ""]).count
    set_unread_gifts_count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream:[
          turbo_stream.replace("content", partial: "buttons/menu/gift_list_response", locals: { total_sender_messages_count: @total_sender_messages_count }),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count })
        ]
      end
    end
  end

  def gift_all
    @gifts = Gift.includes(:gift_category).all
    set_unread_gifts_count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/gift_all_response", locals: { gifts: @gifts }),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count })
      ]
        end
    end
  end

  def send_gift_response
    @my_consultations = Consultation.where(user_id: current_user.id)
    replier_ids = @my_consultations.joins(:replies).pluck('replies.user_id').uniq
    @reply_users = User.where(id: replier_ids)
    @gifts = Gift.all
    set_unread_gifts_count
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

  def user
    @users = User.all
    set_unread_gifts_count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/user_response"),
          turbo_stream.replace('unread-replies-count', partial: 'layouts/unread_replies_count', locals: { user: current_user }),
          turbo_stream.replace("unread-gifts-count", partial: "layouts/unread_gifts_count", locals: { unread_gifts_count: @unread_gifts_count })
        ]
      end
    end
  end

  def user_show
    @user = User.find(params[:id])
    set_unread_gifts_count
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/user_show_response")
        ]
      end
    end
  end

  private

  def set_unread_gifts_count
    @unread_gifts_count = current_user.calculate_unread_gifts_count
  end
end

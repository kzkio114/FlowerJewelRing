class ButtonsController < ApplicationController

  def enter_app
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("response_area", partial: "buttons/enter_app_response"),
          turbo_stream.append("response_area", partial: "buttons/enter_app_response"),
          turbo_stream.replace("enter_app_button", partial: "buttons/without_login_button")
        ]
      end
    end
  end

  def login
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("response_area", partial: "buttons/login_response"),
          turbo_stream.append("response_area", partial: "buttons/login_response"),
          turbo_stream.replace("login_button", partial: "buttons/without_login_button"),
          turbo_stream.replace("content", partial: "buttons/menu/trial_login_response")
        ]
      end
    end
  end

  def menu
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("menu", partial: "buttons/menu/menu_buttons")
      end
    end
  end

  def close_menu
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("menu", partial: "buttons/menu/closed_menu")
      end
    end
  end

  def worries
    @consultations = Consultation.includes(:category).all

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/worries_response")
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


  def consultations_post
    @consultations = Consultation.includes(:category).all

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/consultations_post", locals: { consultations: @consultations })
        ]
      end
    end
  end

  def gift_list
    @total_sent_gifts = Gift.where.not(sent_at: nil).count

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "content",
          partial: "buttons/menu/gift_list_response",
          locals: { total_gifts: @total_gifts }
        )
      end
    end
  end




  def chat
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/chat_response")
        ]
      end
    end
  end


  def gift_all
    @gifts = Gift.includes(:gift_category).all
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "content", 
          partial: "buttons/menu/gift_all_response", 
          locals: { gifts: @gifts }
        )
      end
    end
  end




  def send_gift
    @gifts = Gift.includes(:gift_category).where(sent_at: nil)  # 未送付のギフトのみを取得
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "content", 
          partial: "buttons/menu/send_gift_response", 
          locals: { gifts: @gifts }
        )
      end
    end
  end

  def user
    @users = User.all
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/user_response")
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

end






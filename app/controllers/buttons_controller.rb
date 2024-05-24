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
          turbo_stream.replace("login_button", partial: "buttons/without_login_button")
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
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/worries_response")
        ]
      end
    end
  end

  def gift_list
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/gift_list_response")
        ]
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

  def send_gift
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/send_gift_response")
        ]
      end
    end
  end

  def user
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("content", partial: "buttons/menu/user_response")
        ]
      end
    end
  end



  # def hide_worries
  #   # @worrie_open = false
  #   respond_to do |format|
  #     format.turbo_stream do
  #       render turbo_stream: turbo_stream.replace("worrie", partial: "buttons/menu/worries_content")
  #     end
  #   end
  # end
end

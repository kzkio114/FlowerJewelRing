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
     # @worrie_open = true
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("worrie", partial: "buttons/menu/worries_response")
      end
    end
  end

  def hide_worries
    # @worrie_open = false
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("worrie", partial: "buttons/menu/worries_content")
      end
    end
  end
end

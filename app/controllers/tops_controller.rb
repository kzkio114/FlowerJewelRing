class TopsController < ApplicationController
  def index
    @current_time = Time.zone.now.in_time_zone('Asia/Tokyo')
  end

  def show;end

  def login
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("response_area", partial: "login_response"),
          turbo_stream.replace("login_button", partial: "without_login_button"),
          turbo_stream.replace("content", partial: "buttons/menu/trial_login_response")
        ]
      end
    end
  end

  def enter_app
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("response_area", partial: "enter_app_response")
        ]
      end
    end
  end

  def tos
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("response_area", partial: "tos_response")
        ]
      end
    end
  end

  def pp
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace("response_area", partial: "pp_response")
        ]
      end
    end
  end
end
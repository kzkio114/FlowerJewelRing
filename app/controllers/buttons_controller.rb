class ButtonsController < ApplicationController

  def enter_app
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append("response_area", partial: "buttons/enter_app_response")
      end
    end
  end

  def login
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.append("response_area", partial: "buttons/login_response")
      end
    end
  end
end

class TopController < ApplicationController
  def index
    @current_time = Time.zone.now.in_time_zone('Asia/Tokyo')
  end
end
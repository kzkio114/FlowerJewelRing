class TopController < ApplicationController
  def index
    Rails.logger.info "GOOGLE_CLIENT_SECRET: #{ENV['GOOGLE_CLIENT_SECRET']}"
    Rails.logger.info "GOOGLE_CLIENT_ID: #{ENV['GOOGLE_CLIENT_ID']}"
  end

end
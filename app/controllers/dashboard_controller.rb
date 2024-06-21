class DashboardController < ApplicationController
  def index
    @group_chats = GroupChat.all
    @user = current_user
    @unread_gifts_count = current_user.calculate_unread_gifts_count
  end
end

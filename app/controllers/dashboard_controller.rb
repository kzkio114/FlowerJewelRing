class DashboardController < ApplicationController
  def index
    @group_chats = GroupChat.all
    @user = current_user
    replier_ids = current_user.consultations.joins(:replies).pluck('replies.user_id').uniq
    @received_gifts_from_repliers = current_user.received_gifts.where(giver_id: replier_ids)
  end
end

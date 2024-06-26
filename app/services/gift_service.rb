class GiftService
  def initialize(gift, user)
    @gift = gift
    @user = user
  end

  def send_gift(params)
    @gift.giver_id = @user.id
    @gift.receiver = User.find_by(id: params[:receiver_id])
    @gift.assign_attributes(params)

    return { success: false, error: 'Receiver not found' } if @gift.receiver.nil?

    unread_replies_exist = Reply.joins(:consultation)
                                .where(consultations: { user_id: @gift.giver_id })
                                .where(user_id: @gift.receiver_id, read: false)
                                .exists?

    return { success: false, error: 'No unread replies' } unless unread_replies_exist

    if @gift.save
      mark_latest_reply_as_read
      clear_sender_message
      assign_random_gift_to_user
      { success: true }
    else
      { success: false, error: @gift.errors.full_messages.join(", ") }
    end
  end

  private

  def mark_latest_reply_as_read
    replies_to_mark_read = Reply.joins(:consultation)
                                .where(consultations: { user_id: @gift.giver_id })
                                .where(user_id: @gift.receiver_id, read: false)
                                .order(created_at: :desc)
                                .first
    replies_to_mark_read.update(read: true) if replies_to_mark_read
  end

  def clear_sender_message
    @gift.update(sent_at: Time.current, sender_message: "")
  end

  def assign_random_gift_to_user
    new_gifts = Gift.order("RANDOM()").limit(1)
    new_gifts.each do |new_gift|
      new_gift.update!(giver_id: @user.id, sent_at: nil, receiver_id: nil)
    end
  end
end

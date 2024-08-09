class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_auth "Google"
  end

  def twitter
    handle_auth "Twitter"
  end

  def github
    handle_auth "GitHub"
  end

  def line
    handle_auth "LINE"
  end

  def discord
    handle_auth "Discord"
  end

  def handle_auth(kind)
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.nil?
      flash[:alert] = I18n.t('devise.omniauth_callbacks.failure', kind: kind, reason: "作成または検索できませんでした")
      redirect_to new_user_registration_url
    elsif @user.persisted?
      if @user.previous_changes[:id].present?
        # 新規ユーザーの場合、ランダムなdisplay_nameを割り当てる
        @user.update!(display_name: generate_random_display_name) if @user.display_name.blank?

        # プロフィール編集ページにリダイレクト
        flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: kind)
        sign_in(@user)
        
        # 新規ユーザーにランダムにギフトを与える
        gifts = Gift.order("RANDOM()").limit(5)
        gifts.each do |gift|
          gift.update!(receiver_id: @user.id)
        end
        
        redirect_to edit_user_profile_user_path(@user)
      else
        # 既存のユーザーの場合、通常のログイン処理
        flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: kind)
        sign_in_and_redirect @user, event: :authentication
      end
    else
      session["devise.#{kind}_data"] = request.env['omniauth.auth']
      redirect_to new_user_registration_url
    end
  end

  def failure
    redirect_to root_path
  end

  private

  def generate_random_display_name
    loop do
      random_name = SecureRandom.hex(5) # 例: 10文字のランダムな16進数
      break random_name unless User.exists?(display_name: random_name)
    end
  end
end

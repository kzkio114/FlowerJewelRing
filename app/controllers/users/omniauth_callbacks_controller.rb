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

        @user.update!(display_name: @user.generate_random_display_name) if @user.display_name.blank?
        @user.assign_initial_gifts

        flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: kind)
        sign_in(@user)
        redirect_to edit_user_profile_user_path(@user)
      else
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
end

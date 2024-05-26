class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_auth "Google"
  end

  def discord
    handle_auth "Discord"
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

  def handle_auth(kind)
    @user = User.from_omniauth(request.env['omniauth.auth'])

    if @user.persisted?
      flash[:notice] = I18n.t('devise.omniauth_callbacks.success', kind: kind)
      sign_in_and_redirect @user, event: :authentication, status: :see_other
    else
      session["devise.#{kind.downcase}_data"] = request.env['omniauth.auth'].except('extra')
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end

  def failure
    redirect_to root_path
  end
end
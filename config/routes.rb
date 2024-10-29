Rails.application.routes.draw do

  # ルートのルーティング
  root 'tops#index'

  get 'anime', to: 'tops#show', as: 'anime' # アニメーションのルーティング
  get 'trial', to: 'trials#index', as: 'trial' # お試しページを表示するためのルーティング

  # top(トップ)のルーティング
  scope :tops, controller: :tops do
    post :tos, as: :tops_tos
    post :pp, as: :tops_pp
    post :enter_app, as: :tops_enter_app
    post :login, as: :tops_login
  end

  # Deviseのルーティング
  devise_for :users, skip: [:sessions], controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
    post 'users/auth/google_oauth2/callback', to: 'users/omniauth_callbacks#google_oauth2'
    get '/users/sign_in', to: redirect('/')  # 暫定　ソーシャルログインだけの場合
    delete 'logout', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  # dashboard(ダッシュボード)のルーティング
  authenticate :user do
    resources :dashboards, only: [:index] do
      collection do
        post :menu, to: 'dashboards#menu'
        post :close_menu, to: 'dashboards#close_menu'
        post :info, to: 'dashboards#info'
        post :reset_gift, to: 'dashboards#reset_gift_notifications'
      end
    end
  end

  # search(検索)のルーティング
  scope :search, controller: :search do
    post :search_response
    post :search
  end

  # consultation(コンサルテーション)のルーティング
  resources :consultations, only: [:show, :edit, :update, :create, :destroy] do
    member do
      post 'response', to: 'consultations#consultations_response', as: :response
      get 'select_tone', to: 'consultations#select_tone'
    end
  
    collection do
      post 'worries', to: 'consultations#worries'
      post 'detail', to: 'consultations#consultations_detail'
      post 'consultations_category/:category_id', to: 'consultations#consultations_category'
    end
  
    resources :replies, only: [:new, :create, :destroy]
  end

  # gift(ギフト)のルーティング
  resources :gifts do
    collection do
      post 'all', to: 'gifts#gift_all'
      post 'list', to: 'gifts#gift_list'
      post 'send_gift_response', to: 'gifts#send_gift_response'
    end
  
    member do
      patch :mark_as_read
      post 'send_gift', to: 'gifts#send_gift'
    end
  end
  
  resources :menus1, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
    collection do
      get :gift_list
    end
  end

  # (chat)チャットのルーティング
  resources :chats, only: [:index, :show, :create, :destroy]  do
    collection do
      post 'chat', to: 'chats#chat'
    end
  end

  # (groupchat)グループチャットのルーティング
  resources :group_chats, only: [:new, :index, :edit, :create, :update, :destroy] do
    member do
      post 'add_member', to: 'group_chats#add_member'
      post 'group_chat', to: 'group_chats#group_chat'
      post 'group_chat_list' , to: 'group_chats#group_chat_list'
    end
    # グループチャットのメンバーのルーティング
    resources :group_chat_members, only: [:new, :create, :update, :destroy]
    # グループチャットのメッセージのルーティング
    resources :group_chat_messages, only: [:create, :destroy]
  end

  #User(ユーザー)のルーティング
  resources :users, only: [:show, :update, :destroy] do
    collection do
      post 'user_list', to: 'users#user_list'
      post 'user_list_show', to: 'users#user_list_show'
    end
    member do
      get 'edit', to: 'users#edit', as: 'edit_user_profile'
    end
  end

  # admin(管理画面)のルート
  authenticate :user, ->(u) { u.super_admin? } do
    namespace :admin do
      resources :users, only: [:destroy]
      resources :consultations, only: [:destroy]
      resources :gifts, only: [:destroy]
      get 'dashboards', to: 'dashboards#index'
      post 'dashboards', to: 'dashboards#redirect_to_dashboard'
      resources :admin_users, only: [:index, :edit, :update, :destroy]
    end
  end
end

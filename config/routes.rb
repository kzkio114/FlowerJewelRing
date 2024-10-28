Rails.application.routes.draw do

  # ルートのルーティング
  root 'tops#index'

  get 'anime', to: 'tops#show', as: 'anime' # アニメーションのルーティング

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
    delete 'logout', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  # dashboard(ダッシュボード)のルーティング
  authenticate :user do
    resources :dashboards, only: [:index] do
      collection do
        post :menu
        post :close_menu
        post :info
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

  # ギフトのルーティング

  post 'gifts/gift_list', to: 'gifts#gift_list', as: 'buttons_gift_list'  # ギフト一覧ボタンを押した時のルーティング
  post 'gifts/send_gift_response', to: 'gifts#send_gift_response', as: 'buttons_send_gift_response' # ギフト送信ボタンを押した時のルーティング
  post 'users/user_list', to: 'users#user_list', as: 'buttons_user'  # ユーザーボタンを押した時のルーティング

  # 管理者ユーザー編集用のルート
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


  # 暫定　ソーシャルログインだけの場合
  get '/users/sign_in', to: redirect('/')

  # ダッシュボードのルーティング
  post 'reset_gift_notifications', to: 'dashboards#reset_gift_notifications', as: 'reset_gift_notifications'
  # チャットのルーティング
  resources :chats, only: [:index, :show, :create, :destroy]  # showを追加
  post 'chat', to: 'chats#chat', as: 'custom_chat'
  # その他のルート

  #プライベートチャットのルーティング
  resources :private_chats, only: [:index, :show, :create, :destroy]
  post 'private_chat', to: 'private_chats#private_chat', as: 'custom_private_chat'


  # グループチャットのルーティング
  resources :group_chats, only: [:new, :index, :edit, :create, :update, :destroy] do
    member do
      post 'add_member'
      post 'group_chat'
      post 'group_chat_list'
    end
    resources :group_chat_members, only: [:new, :create, :update, :destroy]
    resources :group_chat_messages, only: [:create, :destroy]
  end

  # ActionCableのサーバー接続エンドポイント
  mount ActionCable.server => '/cable'

  # ボタン内のメニュールーティング（ギフトリスト）
  resources :menus1 do
    collection do
      get :gift_list
    end
  end

  #ユーザーのルーティング
  # config/routes.rb
  resources :users, only: [:show, :update, :destroy] do
    member do
      get 'edit', to: 'users#edit', as: 'edit_user_profile'
    end
  end

# ギフトのルーティング
  post 'gift_all', to: 'gifts#gift_all'

  resources :gifts do
    member do
      patch :mark_as_read
      post 'send_gift', to: 'gifts#send_gift'
    end
  end

  post 'users/user_list_show', to: 'users#user_list_show', as: 'buttons_user_show'  # ユーザーボタンを押した時のルーティング

  get 'trial', to: 'trials#index', as: 'trial' # お試しページを表示するためのルーティング

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end

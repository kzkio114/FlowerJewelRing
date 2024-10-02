Rails.application.routes.draw do

  post 'top/tos', to: 'top#tos', as: :tos  # 利用規約ボタンを押した時のルーティング
  post 'top/pp', to: 'top#pp', as: :pp  # プライバシーポリシーボタンを押した時のルーティング
  post 'top/enter_app', to: 'top#enter_app'  # 説明を見るボタンを押した時のルーティング
  post 'top/login', to: 'top#login', as: 'buttons_login' # ログインボタンを押した時のルーティング

  post 'menu', to: 'dashboards#menu', as: 'menu' # メニューボタンを押した時のルーティング
  post 'close_menu', to: 'dashboards#close_menu', as: 'close_menu' # メニューを閉じるボタンを押した時のルーティング
  post 'dashboards/info', to: 'dashboards#info', as: 'info_buttons' # インフォボタンを押した時のルーティング
  ###
  post 'gifts/gift_list', to: 'gifts#gift_list', as: 'buttons_gift_list'  # ギフト一覧ボタンを押した時のルーティング
  ###
  #post 'buttons/chat', to: 'buttons#chat', as: 'buttons_chat'  # チャットボタンを押した時のルーティング
  post 'gifts/send_gift_response', to: 'gifts#send_gift_response', as: 'buttons_send_gift_response' # ギフト送信ボタンを押した時のルーティング
  post 'users/user_list', to: 'users#user_list', as: 'buttons_user'  # ユーザーボタンを押した時のルーティング
  ###
  post 'consultations/worries', to: 'consultations#worries', as: 'buttons_worries'  # 悩み相談ボタンを押した時のルーティング
  post 'consultations_detail', to: 'consultations#consultations_detail', as: 'consultations_detail'  # 悩み相談ボタンを押した時のルーティング
  # カテゴリー
  post 'consultations_category/:category_id', to: 'consultations#consultations_category', as: 'consultations_category'

  get 'anime', to: 'top#show', as: 'anime' # お試しページを表示するためのルーティング

  # Deviseのルーティング
  devise_for :users, skip: [:sessions], controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  devise_scope :user do
  post 'users/auth/google_oauth2/callback', to: 'users/omniauth_callbacks#google_oauth2'
  delete 'logout', to: 'devise/sessions#destroy', as: :destroy_user_session
  end

  # 管理者ユーザー編集用のルート
  authenticate :user, ->(u) { u.super_admin? } do
    namespace :admin do
      resources :users, only: [:destroy]
      resources :consultations, only: [:destroy]
      resources :gifts, only: [:destroy]
      get 'dashboard', to: 'dashboard#index'
      post 'dashboard', to: 'dashboard#redirect_to_dashboard'
      resources :admin_users, only: [:index, :edit, :update, :destroy]
    end
  end
  # 検索のルーティング
  post 'search_response', to: 'search#search_response'
  post 'search', to: 'search#search'

  # 相談のトーン選択ページのルーティング
  resources :consultations, only: [:show, :edit, :update, :destroy]  do
    post 'response', on: :member, to: 'consultations#consultations_response', as: :response
    get 'select_tone', on: :member, to: 'consultations#select_tone'
    resources :replies, only: [:new, :create, :destroy]
  end

  # ログインしている場合のみアクセスできるページ
  authenticate :user do
    get 'dashboard', to: 'dashboard#index', as: 'dashboard'
  end

  # 暫定　ソーシャルログインだけの場合
  get '/users/sign_in', to: redirect('/')

  # ダッシュボードのルーティング
  post 'reset_gift_notifications', to: 'dashboard#reset_gift_notifications', as: 'reset_gift_notifications'
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

  # メニューのルーティング
  get 'gift_list', to: 'buttons#gift_list'
  # ギフトのルーティング

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

  # config/routes.rb
  resources :consultations do
    post 'response', on: :member, to: 'buttons#consultations_response', as: :consultations_response
  end

  resources :buttons do
    collection do
      post :worries_response
    end
  end


  # ボタン内のメニュールーティング（悩み相談）
  post 'consultations_post', to: 'buttons#consultations_post', as: 'consultations_post'

  root 'top#index' # トップページを表示するためのルーティング

  get 'trial', to: 'trials#index', as: 'trial' # お試しページを表示するためのルーティング

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end

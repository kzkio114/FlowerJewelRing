Rails.application.routes.draw do

  # Deviseのルーティング
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  post 'users/auth/google_oauth2/callback', to: 'users/omniauth_callbacks#google_oauth2'

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

  # 相談のトーン選択ページのルーティング
  resources :consultations do
    post 'response', on: :member, to: 'buttons#consultations_response', as: :response
    get 'select_tone', on: :member, to: 'consultations#select_tone'
  end

  # ログインしている場合のみアクセスできるページ
  authenticate :user do
    get 'dashboard', to: 'dashboard#index', as: 'dashboard'
  end

  #暫定　ソーシャルログインだけの場合
  get '/users/sign_in', to: redirect('/')

  # ダッシュボードのルーティング
  post 'reset_gift_notifications', to: 'dashboard#reset_gift_notifications', as: 'reset_gift_notifications'
  post 'buttons/info', to: 'buttons#info', as: 'info_buttons'
  # チャットのルーティング
  resources :chats, only: [:index, :show, :create, :destroy]  # showを追加
  post 'chat', to: 'chats#chat', as: 'custom_chat'
  # その他のルート

  #プライベートチャットのルーティング
  resources :private_chats, only: [:index, :show, :create, :destroy]
  post 'private_chat', to: 'private_chats#private_chat', as: 'custom_private_chat'

  post 'buttons/tos', to: 'buttons#tos', as: :tos  # 利用規約ボタンを押した時のルーティング
  post 'buttons/pp', to: 'buttons#pp', as: :pp  # プライバシーポリシーボタンを押した時のルーティング


  # グループチャットのルーティング
  resources :group_chats, only: [:new, :index, :edit, :create, :update, :destroy] do
    member do
      post 'add_member'
      post 'group_chat'
      post 'group_chat_list'
    end
    resources :group_chat_members, only: [:new, :create, :destroy]
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


  post 'gift_all', to: 'buttons#gift_all'

  resources :gifts do
    member do
      patch :mark_as_read
      post 'send_gift', to: 'gifts#send_gift'
    end
  end
  # カテゴリー
  post 'consultations_category/:category_id', to: 'buttons#consultations_category', as: 'consultations_category'

  #悩みの削除（詳細）
  delete 'consultations/:id', to: 'buttons#consultations_destroy', as: 'consultations_destroy'

  post 'buttons/user_show', to: 'buttons#user_show', as: 'buttons_user_show'  # ユーザーボタンを押した時のルーティング

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
  #post 'consultations_response', to: 'buttons#consultations_response', as: 'consultations_response'
  post 'consultations_detail', to: 'buttons#consultations_detail', as: 'consultations_detail'
  # ボタン内のメニュールーティング（悩み相談）

  resources :consultations do
    post 'destroy_reply', to: 'buttons#consultations_destroy_reply', as: :destroy_reply
    resources :replies, only: [:new, :create]
  end

  # ボタン内のメニュールーティング（悩み相談）
  post 'consultations_post', to: 'buttons#consultations_post', as: 'consultations_post'

 
  root 'top#index' # トップページを表示するためのルーティング

  get 'trial', to: 'trials#index', as: 'trial' # お試しページを表示するためのルーティング

  # ボタンを押した時のルーティング

  post 'menu', to: 'buttons#menu', as: 'menu' # メニューボタンを押した時のルーティング
  post 'close_menu', to: 'buttons#close_menu', as: 'close_menu' # メニューを閉じるボタンを押した時のルーティング

  post 'buttons/worries', to: 'buttons#worries', as: 'buttons_worries'  # 悩み相談ボタンを押した時のルーティング
  # post 'buttons/hide_worries', to: 'buttons#hide_worries', as: 'buttons_hide_worries'  # 悩み相談を閉じるボタンを押した時のルーティング
  post 'buttons/gift_list', to: 'buttons#gift_list', as: 'buttons_gift_list'  # ギフト一覧ボタンを押した時のルーティング
  post 'buttons/chat', to: 'buttons#chat', as: 'buttons_chat'  # チャットボタンを押した時のルーティング
  post 'buttons/send_gift_response', to: 'buttons#send_gift_response', as: 'buttons_send_gift_response' # ギフト送信ボタンを押した時のルーティング
  post 'buttons/user', to: 'buttons#user', as: 'buttons_user'  # ユーザーボタンを押した時のルーティング

  post 'buttons/enter_app', to: 'buttons#enter_app'  # 説明を見るボタンを押した時のルーティング
  post 'buttons/login', to: 'buttons#login', as: 'buttons_login' # ログインボタンを押した時のルーティング
  post 'buttons/without_login', to: 'buttons#without_login' # ログインせずに使うボタンを押した時のルーティング

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end

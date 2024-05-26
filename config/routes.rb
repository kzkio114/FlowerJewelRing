Rails.application.routes.draw do

  # Deviseのルーティング
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  # ログインしている場合のみアクセスできるページ
  authenticate :user do
    get 'dashboard', to: 'dashboard#index'
  end
  root 'top#index' # トップページを表示するためのルーティング

  get 'trial', to: 'trials#index', as: 'trial' # お試しページを表示するためのルーティング

  # ボタンを押した時のルーティング

  post 'menu', to: 'buttons#menu', as: 'menu' # メニューボタンを押した時のルーティング
  post 'close_menu', to: 'buttons#close_menu', as: 'close_menu' # メニューを閉じるボタンを押した時のルーティング

  post 'buttons/worries', to: 'buttons#worries', as: 'buttons_worries'  # 悩み相談ボタンを押した時のルーティング
  # post 'buttons/hide_worries', to: 'buttons#hide_worries', as: 'buttons_hide_worries'  # 悩み相談を閉じるボタンを押した時のルーティング
  post 'buttons/gift_list', to: 'buttons#gift_list', as: 'buttons_gift_list'  # ギフト一覧ボタンを押した時のルーティング
  post 'buttons/chat', to: 'buttons#chat', as: 'buttons_chat'  # チャットボタンを押した時のルーティング
  post 'buttons/send_gift', to: 'buttons#send_gift', as: 'buttons_send_gift'  # ギフト送信ボタンを押した時のルーティング
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

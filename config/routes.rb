Rails.application.routes.draw do
  # メニューのルーティング
  get 'gift_list', to: 'buttons#gift_list'
  # ギフトのルーティング
  resources :gifts
  # ボタン内のメニュールーティング（ギフトリスト）
  resources :menus1 do
    collection do
      get :gift_list
    end
  end

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
    resources :replies, only: [:new, :create]
  end

  # ボタン内のメニュールーティング（悩み相談）
  post 'consultations_post', to: 'buttons#consultations_post', as: 'consultations_post'

  resources :buttons do
    post 'send_gift', on: :collection
  end

  
  # Deviseのルーティング
  devise_for :users, controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
  post 'users/auth/google_oauth2/callback', to: 'users/omniauth_callbacks#google_oauth2'

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

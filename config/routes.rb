Rails.application.routes.draw do

  root 'top#index' # トップページを表示するためのルーティング
  get 'trial', to: 'top#trial', as: 'trial' # お試しページを表示するためのルーティング

  # ボタンを押した時のルーティング
  post 'buttons/enter_app', to: 'buttons#enter_app'  # 説明を見るボタンを押した時のルーティング
  post 'buttons/login', to: 'buttons#login' # ログインボタンを押した時のルーティング
  post 'buttons/without_login', to: 'buttons#without_login' # ログインせずに使うボタンを押した時のルーティング

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end

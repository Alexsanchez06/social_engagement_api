require 'sidekiq/web'
require 'sidekiq/cron/web'

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  scope :path => '/api' do  
    resources :users do
      member do
        get :stats
        get :social_activities
        post :claim_request
        get :claims
      end
    end
  end

  get '/api/stats' => 'application#stats'
  get '/api/full_stats' => 'application#full_stats'  
  get '/api/leader_board' => 'application#leader_board'
  get '/api/clear_cache/:key' => 'application#clear_cache'
  get '/api/success_failure' => 'application#success_failure'
  get '/api/export' => 'application#export'
  get '/api/get_app_config' => 'application#get_app_config'
  put 'api/update_app_config' => 'application#update_app_config'
  post 'api/create_airdrop' => 'application#create_airdrop'
  get 'api/live_airdrop' => 'application#live_airdrop'
  delete 'api/delete_airdrop' => 'application#delete_airdrop'

  get '/authenticate/reverify', to: 'sessions#reverify_authentication'
  get '/authenticate/verify', to: 'sessions#verify_authentication'  
  get '/authenticate/:provider', to: 'sessions#authenticate'  

  # Omni Auth  
  post '/auth/twitter/callback', to: 'sessions#create'
  get '/auth/twitter/callback', to: 'sessions#create'

  get '/api/sync', to: 'users#sync' if AppConfig.enable_sync
  
  # Defines the root path route ("/")
  # root "articles#index"
  mount Sidekiq::Web => '/api/sidekiq'
end

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  mount Sidekiq::Web => "/ops/sidekiq" if Rails.env.development?
  namespace :api do
    namespace :v1 do
      post "session", to: "sessions#create"
      get "me", to: "sessions#show"
      get "dashboard", to: "dashboard#show"
      resources :employees, only: %i[index show create update] do
        resources :salary_records, only: %i[create], controller: "salary_records"
      end
    end
  end
end

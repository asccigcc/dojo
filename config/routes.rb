Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resource :session, only: %i[new create destroy]
  resources :exercises, only: %i[index show], param: :slug do
    resources :submissions, only: :create
    resource :solution, only: :show
  end

  root "home#show"
end

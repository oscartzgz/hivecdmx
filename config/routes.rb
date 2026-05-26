Rails.application.routes.draw do
  root "rooms#index"

  resources :rooms,   only: [ :index, :show ]
  resources :records, only: [ :update ] do
    resources :photos, only: [ :create, :show ]
  end
  resources :reports, only: [ :show ] do
    collection { get :export }
  end

  namespace :admin do
    resources :users
    resources :records, only: [ :index ]
  end

  # Generado por rails generate authentication:
  resource  :session
  resources :passwords, param: :token
end

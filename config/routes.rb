Rails.application.routes.draw do
  root "rooms#index"

  resources :rooms,   only: [ :index, :show ]
  patch "/records/*id",                    to: "records#update",  as: :record,          format: false
  post  "/records/*record_id/comments",    to: "comments#create", as: :record_comments, format: false
  resource :reports, only: [ :show ] do
    get :export, on: :member
  end

  namespace :admin do
    resources :users
    resources :records, only: [ :index ]
  end

  # Generado por rails generate authentication:
  resource  :session
  resources :passwords, param: :token
end

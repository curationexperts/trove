ALLOW_DOTS ||= /[a-zA-Z0-9_.:]+/

Rails.application.routes.draw do

  get 'about', to: 'pages#about', as: 'about'
  get 'contact', to: 'pages#contact', as: 'contact'

  resources :downloads, only: [:show], constraints: { id: ALLOW_DOTS }

  resources :course_collections do
    patch :append_to, on: :member
  end
  resources :personal_collections do
    patch :append_to, on: :member
  end

  root to: "catalog#index"
  blacklight_for :catalog, constraints: { id: ALLOW_DOTS }
  devise_for :users
end

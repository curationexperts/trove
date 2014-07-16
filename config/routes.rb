ALLOW_DOTS ||= /[a-zA-Z0-9_.:]+/

Rails.application.routes.draw do

  get 'about', to: 'pages#about', as: 'about'
  get 'contact', to: 'pages#contact', as: 'contact'

  resources :downloads, only: [:show], constraints: { id: ALLOW_DOTS }

  resources :course_collections, constraints: { id: ALLOW_DOTS } do
    member do
      post :collections
      patch :append_to
      delete :remove_from
      patch :update_type
    end
  end
  resources :personal_collections, constraints: { id: ALLOW_DOTS } do
    member do
      post :collections
      patch :append_to
      delete :remove_from
      patch :update_type
    end
  end

  root to: "catalog#index"
  blacklight_for :catalog, constraints: { id: ALLOW_DOTS }
  devise_for :users
end

ALLOW_DOTS ||= /[^\/]+(?=\.(html|json|pptx|pdf)\z)|[^\/]+/

Rails.application.routes.draw do

  get 'about', to: 'pages#about', as: 'about'
  get 'help', to: 'pages#help', as: 'help'
  get 'contact', to: 'pages#contact', as: 'contact'

  resources :downloads, only: [:show], constraints: { id: ALLOW_DOTS }

  patch 'catalog/:id/add_to_collection', to: 'catalog#add_to_collection', as: 'add_to_collection_catalog', constraints: { id: ALLOW_DOTS }

  resources :course_collections, constraints: { id: ALLOW_DOTS } do
    member do
      post :copy
      patch :append_to
      patch :update_type
    end
    resources :members, only: :show, constraints: { id: /[1-9][0-9]*/ }
  end

  resources :personal_collections, constraints: { id: ALLOW_DOTS } do
    member do
      post :copy
      patch :append_to
      patch :update_type
    end
    resources :members, only: :show, constraints: { id: /[1-9][0-9]*/ }
  end

  root to: "catalog#index"
  blacklight_for :catalog, constraints: { id: ALLOW_DOTS }
  devise_for :users
end

ALLOW_DOTS ||= /[^\/]+(?=\.(html|json|pptx)\z)|[^\/]+/

Rails.application.routes.draw do

  get 'about', to: 'pages#about', as: 'about'
  get 'contact', to: 'pages#contact', as: 'contact'

  resources :downloads, only: [:show], constraints: { id: ALLOW_DOTS }

  patch 'catalog/:id/add_to_collection', to: 'catalog#add_to_collection', as: 'add_to_collection_catalog', constraints: { id: ALLOW_DOTS }

  resources :course_collections, constraints: { id: ALLOW_DOTS } do
    member do
      post :copy
      patch :append_to
      delete :remove_from
      patch :update_type
    end
  end
  resources :personal_collections, constraints: { id: ALLOW_DOTS } do
    member do
      post :copy
      patch :append_to
      delete :remove_from
      patch :update_type
    end
  end

  root to: "catalog#index"
  blacklight_for :catalog, constraints: { id: ALLOW_DOTS }
  devise_for :users
end

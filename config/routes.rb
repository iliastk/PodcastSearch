Rails.application.routes.draw do
  
  root 'requests#index'

  resources :results do get :index end
 

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

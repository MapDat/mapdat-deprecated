Rails.application.routes.draw do
  get 'home/buildings', to: 'home#buildings'
  get 'login/new', to: 'login#new'
  get 'home/points_of_interest'

  root 'home#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

Rails.application.routes.draw do
  get 'leaflet/index'

  root 'leaflet#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

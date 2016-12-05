Rails.application.routes.draw do
  get 'home/buildings', to: 'home#buildings'
  get 'login/new', to: 'login#new'
  get 'home/points_of_interest'

  get '/login' => 'sessions#new'
  post '/login' => 'sessions#create'
  get '/logout' => 'sessions#destroy'

  get '/signup' => 'user#new'
  post '/users' => 'user#create'
  get '/settings' => 'user#show'
  post '/settings/update' => 'user#update'

  post '/show_poi' => 'home#show_poi'
  post '/hide_poi' => 'home#hide_poi'

  post '/show_south_study' => 'home#show_south_study'
  post '/hide_south_study' => 'home#hide_south_study'

  post '/show_query3' => 'home#show_query3'
  post '/hide_query3' => 'home#hide_query3'

  post '/show_food_and_study' => 'home#show_food_and_study'
  post '/hide_food_and_study' => 'home#hide_food_and_study'

  post '/show_north_museum' => 'home#show_north_museum'
  post '/hide_north_museum'=> 'home#hide_north_museum'

  get '/info' => 'home#building_info'

  post '/review/new/' => 'home#add_review'

  get '/user_image' => 'user#profile_picture'


  root 'home#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

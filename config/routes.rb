Rails.application.routes.draw do
  root to: 'games#game'

  get '/game', to: 'games#game'

  get '/score', to: 'games#score'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

Rails.application.routes.draw do
  root "players#index"

  resources :players, only: %i[index show new create destroy]
  resources :matches, only: %i[index new create destroy]
end

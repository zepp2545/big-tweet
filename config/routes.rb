Rails.application.routes.draw do
  get '/confirm/:id',to: 'posts#confirm',as: :confirm
  resources :posts,only: %i(create edit update show)
  root to: "posts#new"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

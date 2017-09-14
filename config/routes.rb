Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "homepage#index", as: "home"

  get "/search", to: "search#search", as: "search"
  get "/random", to: "illustrations#random", as: "random_illustration"
  get "/illustration/:id", to: "illustrations#show", as: "show_illustration"
  post "/illustration/:id/submit", to: "illustrations#submit_tags", as: "submit_illustration_tags"
  post "/illustration/:id/create", to: "illustrations#create_tags", as: "create_illustration_tags"
  post "/tags/dispute", to: "tags#dispute"

end

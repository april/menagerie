Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root to: "pages#index", as: "home"

  get "/search", to: "search#search", as: "search"
  get "/tagging-guide", to: "pages#guide", as: "guide"

  get "/illustration/random", to: "illustrations#random", as: "random_illustration"
  get "/illustration/:id", to: "illustrations#show", as: "show_illustration"
  post "/illustration/:id/submit", to: "illustrations#submit_tags", as: "submit_illustration_tags"
  post "/illustration/:id/create", to: "illustrations#create_tags", as: "create_illustration_tags"
  post "/tags/:id/dispute", to: "tags#dispute", as: "dispute_illustration_tag"
  post "/tags/:id/confirm", to: "tags#confirm", as: "confirm_illustration_tag"

  get "/admin", to: "admin#index", as: "admin"

end

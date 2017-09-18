Rails.application.routes.draw do

  get  "admin/signin", to:"admin/sessions#new", as:"admin_new_session"
  post "admin/signin", to:"admin/sessions#request_grant"
  get  "admin/authenticate", to:"admin/sessions#authenticate", as:"admin_authenticate_session"
  post "admin/authenticate", to:"admin/sessions#create"
  delete "admin/signout", to:"admin/sessions#destroy", as:"admin_destroy_session"

  get "admin", to: "admin/illustration_tags#index", as: "admin_dashboard"
  post "admin/confirm/:id", to: "admin/illustration_tags#confirm", as: "admin_confirm_illustration_tag"

  root to: "pages#home", as: "home"
  get "/search", to: "search#search", as: "search"
  get "/tagging-guide", to: "pages#guide", as: "guide"

  get "/illustration/random", to: "illustrations#random", as: "random_illustration"
  get "/illustration/:slug", to: "illustrations#show", as: "show_illustration"
  post "/tags/submit/:illustration_id", to: "tags#submit", as: "submit_illustration_tags"
  post "/tags/create/:tag_submission_id", to: "tags#create", as: "create_illustration_tags"
  post "/tags/dispute/:illustration_tag_id", to: "tags#dispute", as: "dispute_illustration_tag"

end

Rails.application.routes.draw do

  get  "admin/signin", to:"admin/sessions#new", as:"admin_new_session"
  post "admin/signin", to:"admin/sessions#request_grant"
  get  "admin/authenticate", to:"admin/sessions#authenticate", as:"admin_authenticate_session"
  post "admin/authenticate", to:"admin/sessions#create"
  delete "admin/signout", to:"admin/sessions#destroy", as:"admin_destroy_session"

  get "admin", to: "admin/content_tags#approve", as: "admin_approve_tags"
  post "admin/content_tags/confirm/:id", to: "admin/content_tags#confirm", as: "admin_confirm_content_tag"
  get "admin/tags", to: "admin/tags#index", as: "admin_tags_index"
  get "admin/illustrations", to: "admin/illustrations#index", as: "admin_illustrations"
  get "admin/illustrations/:id", to: "admin/illustrations#edit", as: "admin_edit_illustrations"
  post "admin/illustrations/:id", to: "admin/illustrations#update", as: "admin_update_illustrations"

  root to: "pages#home", as: "home"
  get "/tagging-guide", to: "pages#guide", as: "guide"
  get "/terms-of-service", to: "pages#tos", as: "tos"
  get "/privacy-policy", to: "pages#privacy", as: "privacy"

  get "/search", to: "search#search", as: "search"
  get "/autocomplete", to: "search#autocomplete", as: "autocomplete"

  get "/tagging/random", to: "taggables#random", as: "random_illustration"
  get "/tagging/:slug", to: "taggables#show", as: "show_illustration"

  post "/tags/submit/:id", to: "tags#submit", as: "submit_tags"
  post "/tags/create/:id", to: "tags#create", as: "create_content_tags"
  post "/tags/dispute/:id", to: "tags#dispute", as: "dispute_content_tag"

end

Rails.application.routes.draw do

  get  "admin/signin", to:"admin/sessions#new", as:"admin_new_session"
  post "admin/signin", to:"admin/sessions#request_grant"
  get  "admin/authenticate", to:"admin/sessions#authenticate", as:"admin_authenticate_session"
  post "admin/authenticate", to:"admin/sessions#create"
  delete "admin/signout", to:"admin/sessions#destroy", as:"admin_destroy_session"

  get "admin", to: "admin/content_tags#index", as: "admin_dashboard"
  post "admin/tags/confirm/:id", to: "admin/content_tags#confirm", as: "admin_confirm_content_tag"
  get "admin/illustrations", to: "admin/illustrations#index", as: "admin_manage_illustrations"
  get "admin/illustrations/:id", to: "admin/illustrations#edit", as: "admin_edit_illustrations"
  post "admin/illustrations/:id", to: "admin/illustrations#update", as: "admin_update_illustrations"

  root to: "pages#home", as: "home"
  get "/search", to: "search#search", as: "search"
  get "/tagging-guide", to: "pages#guide", as: "guide"
  get "/terms-of-service", to: "pages#tos", as: "tos"
  get "/privacy-policy", to: "pages#privacy", as: "privacy"

  get "/tagging/random", to: "taggables#random", as: "random_illustration"
  get "/tagging/:slug/illustration", to: "taggables#illustration", as: "show_illustration"
  get "/tagging/:slug/oracle_card", to: "taggables#oracle_card", as: "show_oracle_card"

  post "/tags/submit/illustration/:id", to: "tags#submit_illustration_tags", as: "submit_illustration_tags"
  post "/tags/submit/oracle_card/:id", to: "tags#submit_oracle_card_tags", as: "submit_oracle_card_tags"
  post "/tags/create/:id", to: "tags#create", as: "create_content_tags"
  post "/tags/dispute/:id", to: "tags#dispute", as: "dispute_content_tag"

end

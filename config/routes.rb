Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "/api/get", to: "downloader#show"
  root "downloader#index"
end

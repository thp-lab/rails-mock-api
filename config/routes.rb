Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :graph, only: [ :index, :create ]
    end
  end
end

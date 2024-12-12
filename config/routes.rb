Rails.application.routes.draw do
  # NLP route
  post 'nlp/generate', to: 'nlp#generate'

  # HTML view route
  root 'triple#index'
  resources :triple, only: [ :index, :create ]

  # API routes
  namespace :api do
    namespace :v1 do
      resources :graph, only: [ :index, :create ]
    end
  end

  #CSV Export route
  get '/export-csv', to: 'export#csv'
end

# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "http://127.0.0.1:5173"  # In production, replace with your frontend domain

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ]
  end
end

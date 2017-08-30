Rails.application.routes.draw do

  concern :batchable do
    collection do
      get  :batch
      post :batch, action: :batch_edit_and_new
      put  :batch_update_and_create
    end
  end

  # Route '/' to a 'root' action which will check app config to either
  ## redirect it as a custom short URL, or render the home page.
  root 'application#root'

  get '/admin', to: 'static_pages#home' # Enables root_or_admin_[url, path] helpers

  scope '/admin' do
    resources :users

    # Use short URL slug as id in URL
    resources :short_urls, param: :slug, path: 'short-urls', concerns: :batchable do
      get 'search', on: :collection
    end
  end

  get     '/login',  to: 'sessions#new'
  post    '/login',  to: 'sessions#create'
  delete  '/logout', to: 'sessions#destroy'
  get     '/logout', to: 'sessions#delete'

  # fall back to redirects if no routes match
  get     '/*slug',  to: 'short_url_requests#show'
end

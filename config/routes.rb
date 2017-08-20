Rails.application.routes.draw do

  # Route '/' to a 'root' action which will check app config to either
  ## redirect it as a custom short URL, or render the home page.
  root 'application#root'

  get '/admin', to: 'static_pages#home' # Enables root_or_admin_[url, path] helpers

  scope '/admin' do
    resources :users
    # Expose screen for creating many short URLs
    get 'short-urls/many-new', to: 'short_urls#many_new'

    # Use short URL slug as id in URL
    resources :short_urls, param: :slug, path: 'short-urls' do
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

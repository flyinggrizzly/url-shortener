Rails.application.routes.draw do

  # Route '/' to a custom location in production
  if UrlGrey::Application.config.root_redirect_enabled
    get '/', to: redirect(UrlGrey::Application.config.root_redirect_url)
  else
    root 'static_pages#home'
  end

  get '/admin', to: 'static_pages#home'
  scope '/admin' do
    resources :users
    resources :short_urls do
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

Rails.application.routes.draw do
  root 'static_pages#home'

  scope '/admin' do
    resources :users
    resources :short_urls
  end

  get     '/login',  to: 'sessions#new'
  post    '/login',  to: 'sessions#create'
  delete  '/logout', to: 'sessions#destroy'
  get     '/logout', to: 'sessions#delete'
end

Bspace::Application.routes.draw do
	root to: 'homepage#index'

	devise_scope :user do
    	match '/login' => 'sessions#new', as: 'login'
    	match '/logout' => 'sessions#destroy', method: :delete, as: 'logout'
    	match '/register' => 'registrations#new', as: 'register'
    end

    devise_for :users, :controllers => { :omniauth_callbacks => 'oauth_credentials', :registrations => 'registrations', :sessions => 'sessions' }
end

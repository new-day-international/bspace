Bspace::Application.routes.draw do
	root to: 'homepage#index'

	resources :contacts
	resources :nominations
	resources :spaces
	resources :votes


	resources :admin, :only => :index do
		collection do
			get :app_events
			get :blog
			get :pages
			get :users
		end
	end

	devise_scope :user do
    	match '/login' => 'sessions#new', as: 'login'
    	match '/logout' => 'sessions#destroy', method: :delete, as: 'logout'
    	match '/register' => 'registrations#new', as: 'register'
    end

    devise_for :users, :controllers => { :omniauth_callbacks => 'oauth_credentials', :registrations => 'registrations', :sessions => 'sessions' }

    match '/home' => 'users#home', as: 'user_home'
    match '/settings' => 'users#settings', as: 'user_settings'
    match 'members' => 'users#index', as: 'members'

end

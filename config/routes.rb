Rails.application.routes.draw do
  devise_for :users, controllers: {
        registrations: 'users/registrations',
        sessions: 'users/sessions',
      }
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :users, only: [], path: 'users' do
  	collection do
  		get 	'/pay_now' => 					'users#pay_now'
  		get 	'create_payment_intent' =>		'users#create_payment_intent'
  	end
  	member do 
  		get 	'payment_history'		=> 		'users#payment_history'
  		get 	'payment_confirmation'	=> 		'users#payment_confirmation'
  		get 	'save_card'				=> 		'users#save_card'
  	end
  end

  post '/webhook/payment_attempt' 		=> 		'users#payment_attempt'

  root to: "home#index"
end

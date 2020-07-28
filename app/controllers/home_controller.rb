class HomeController < ApplicationController
	before_action :authenticate_user! 
	def index
		@cards = current_user.user_cards.order(created_at: :desc)
	end
end

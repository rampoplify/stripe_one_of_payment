class HomeController < ApplicationController
	before_action :authenticate_user! 
	def index
		@cards = current_user.user_cards.limit(4)
		respond_to do |format|
	      format.html { render '/home/index3'}
	    end
	end
end

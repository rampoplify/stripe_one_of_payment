class HomeController < ApplicationController
	def index
		if user_signed_in? 
			@cards = current_user.user_cards.limit(4)
			respond_to do |format|
		      format.html { render '/home/index3'}
		    end
		else
			redirect_to new_user_session_path
		end
	end
end

class UsersController < ApplicationController
	before_action :authenticate_user! 

	def create_payment_intent
		if params[:amount].present?
			begin
				@payment_intent = Stripe::PaymentIntent.create(amount: params[:amount].to_i * 100, currency: 'usd', customer: current_user.customer_id)
			rescue Exception => e
				flash[:notice] = 'Stripe error'
			end
			respond_to do |format|
				format.js {render '/users/js/create_payment_intent'}
			end
		end
	end
	# def pay_now
	# 	if params[:token].present? && current_user.customer_id.present?
	# 		begin
	# 			source_card = Stripe::Customer.create_source(current_user.customer_id, {source: params[:token]})
	# 			user_card = UserCard.create!(user_id: current_user.id, exp_month: source_card.exp_month, exp_year: source_card.exp_year, last_4: source_card.last4, card_type: source_card.brand, card_number: source_card.id)
	# 		rescue Exception => e
	# 			flash[:notice] = 'Stripe error'
	# 		end
	# 	elsif params[:card_id].present?
	# 		begin
	# 			source_card = Stripe::Customer.retrieve_source(current_user.customer_id, params[:card_id])
	# 		rescue Exception => e
	# 			flash[:notice] = 'Stripe error'
	# 		end
	# 	else
	# 		flash[:notice] = 'Argument error'
	# 	end
	# 	begin
	# 		Stripe::PaymentIntent.update(params[:payment_intent], {payment_method: source_card, customer: current_user.customer_id})
	# 		payment = Stripe::PaymentIntent.confirm(params[:payment_intent])
	# 		if payment.status == 'succeeded'
	# 			flash[:notice] = 'Payment success.'
	# 		elsif payment.status == "requires_action"
	# 			redirect_url_next = payment.next_action.use_stripe_sdk.stripe_js
	# 		end
	# 		payment_detail = PaymentDetail.create!(user_id: current_user.id, amount: payment.amount/100, payment_intent: payment.id)
	# 	rescue Exception => e
	# 		flash[:notice] = 'Stripe error'
	# 	end
	# 	if redirect_url_next.present?
	# 		redirect_to redirect_url_next
	# 	else
	# 		redirect_to root_path
	# 	end
	# end

	def payment_history
		@payment_history = User.find(params[:id]).payment_details
	end
	def payment_confirmation
		begin
			card = Stripe::PaymentMethod.retrieve(params[:payment_intent][:payment_method])
			payment_detail = PaymentDetail.create!(user_id: current_user.id, amount: params[:payment_intent][:amount].to_i/100, payment_intent: params[:payment_intent][:id])
			card_exist = UserCard.card_exist(params[:payment_intent][:payment_method])
			if params[:payment_intent][:setup_future_usage] != ''
				user_card = UserCard.create!(user_id: current_user.id, exp_month: card[:card].exp_month, exp_year: card[:card].exp_year, last_4: card[:card].last4, card_type: card[:card].brand, card_number: params[:payment_intent][:payment_method]) unless card_exist.present?
			end
			flash[:notice] = 'Payment Success'
		rescue Exception => e 
			flash[:notice] = 'Error while getting Payment Method'
		end
		render js: "window.location.pathname='#{payment_history_user_path}'" 
	end
	def save_card
		intent = Stripe::PaymentIntent.update(params[:payment_intent], {setup_future_usage: params[:checked] == "true" ? 'on_session' : ''})
		puts intent
		render json: {payment_intent: intent}
	end
end


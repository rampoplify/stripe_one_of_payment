class UsersController < ApplicationController

	def create_payment_intent
		if params[:amount].present?
			begin
				@payment_intent = Stripe::PaymentIntent.create(amount: params[:amount].to_i * 100, currency: 'usd')
			rescue Exception => e
				flash[:notice] = 'Stripe error'
			end
			respond_to do |format|
				format.js {render '/users/js/create_payment_intent'}
			end
		end
	end
	def pay_now
		if params[:token].present? && current_user.customer_id.present?
			begin
				source_card = Stripe::Customer.create_source(current_user.customer_id, {source: params[:token]})
				user_card = UserCard.create!(user_id: current_user.id, exp_month: source_card.exp_month, exp_year: source_card.exp_year, last_4: source_card.last4, card_type: source_card.brand, card_number: source_card.id)
			rescue Exception => e
				flash[:notice] = 'Stripe error'
			end
		elsif params[:card_id].present?
			begin
				source_card = Stripe::Customer.retrieve_source(current_user.customer_id, params[:card_id])
			rescue Exception => e
				flash[:notice] = 'Stripe error'
			end
		else
			flash[:notice] = 'Argument error'
		end
		begin
			Stripe::PaymentIntent.update(params[:payment_intent], {payment_method: source_card, customer: current_user.customer_id})
			payment = Stripe::PaymentIntent.confirm(params[:payment_intent])
			payment_detail = PaymentDetail.create!(user_id: current_user.id, amount: payment.amount/100, payment_intent: payment.id)
			if payment.status == 'succeeded'
				flash[:notice] = 'Payment success.'
			end
		rescue Exception => e
			flash[:notice] = 'Stripe error'
		end
		redirect_to root_path
	end

end


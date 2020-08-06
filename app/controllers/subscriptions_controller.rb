class SubscriptionsController < ApplicationController
	protect_from_forgery unless: -> { request.format.json? }
	def index
		
	end
	def show
		customer = Stripe::Customer.retrieve(current_user.customer_id)
		if customer.present? && customer.subscriptions.present? 
			if customer.subscriptions.data.pluck(:plan).pluck(:id).include?(params[:id])
				# redirect_to active_subscriptions_path and return
			end
		end
	end

	def active_subscription
		
	end

	def plans
		
	end
	def retry_invoice
		begin
    		Stripe::PaymentMethod.attach( params[:payment_method], { customer: current_user.customer_id } )
  		rescue Stripe::CardError => e
    		puts e
 		end

  		Stripe::Customer.update( current_user.customer_id, invoice_settings: { default_payment_method: params[:payment_method] } )
	  	invoice = Stripe::Invoice.retrieve( { id: params[:invoice_id], expand: %w[payment_intent subscription] } )
	  	render json: {invoice: invoice}
	end

	def create_subscription
		begin
			customer_payment_method = Stripe::PaymentMethod.attach(params[:payment_method], {customer: current_user.customer_id})
			customer_default_payment_method = Stripe::Customer.update( current_user.customer_id, invoice_settings: { default_payment_method: params[:payment_method] })
			subscription = Stripe::Subscription.create({ customer: current_user.customer_id, items: [{price: params[:price_id]}]}, payment_method: params[:payment_method] )
			# subscription = Stripe::Subscription.create({ customer: current_user.customer_id, items: [{price: params[:price_id]}], expand: %w[latest_invoice.payment_intent]}, payment_method: params[:payment_method] )
			latest_invoice = Stripe::Invoice.retrieve(subscription.latest_invoice)
			payment_intent = Stripe::PaymentIntent.retrieve(latest_invoice.payment_intent)
			# error = false
		rescue Exception => e
			flash[:notice] = 'This is not available'
		end
		# if error == false
			render json: {subscription: subscription, payment_intent: payment_intent}
		# end
	end
end

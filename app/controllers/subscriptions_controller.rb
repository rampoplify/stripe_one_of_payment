class SubscriptionsController < ApplicationController
	protect_from_forgery unless: -> { request.format.json? }

	def index
		@customer = Stripe::Customer.retrieve(current_user.customer_id)
		@subscriptions = @customer.subscriptions if @customer.present?
	end
	def show
		@cards = current_user.user_cards.order(created_at: :desc)
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
			@customer = Stripe::Customer.retrieve(current_user.customer_id)
			if @customer.present? && @customer.subscriptions.present? 
				flash[:notice] = 'This customer have already active plan.'
				redirect_to root_path and return
			else
				customer_payment_method = Stripe::PaymentMethod.attach(params[:payment_method], {customer: current_user.customer_id})
				customer_default_payment_method = Stripe::Customer.update( current_user.customer_id, invoice_settings: { default_payment_method: params[:payment_method] })
				subscription = Stripe::Subscription.create({ customer: current_user.customer_id, items: [{price: params[:price_id]}]}, payment_method: params[:payment_method] )
				# subscription = Stripe::Subscription.create({ customer: current_user.customer_id, items: [{price: params[:price_id]}], expand: %w[latest_invoice.payment_intent]}, payment_method: params[:payment_method] )
				latest_invoice = Stripe::Invoice.retrieve(subscription.latest_invoice)
				if latest_invoice.payment_intent.present?
					payment_intent = Stripe::PaymentIntent.retrieve(latest_invoice.payment_intent)
				end
			end
		rescue Exception => e
			flash[:notice] = 'This is not available'
		end
		render json: {subscription: subscription, payment_intent: payment_intent}
	end


	def subscriptions_new		
		@customer = Stripe::Customer.retrieve(current_user.customer_id)
		if @customer.present? && @customer.subscriptions.present? 
			redirect_to subscription_plans_path(@customer.subscriptions.data[0].id) and return
		else
			@prices = Stripe::Price.list(product: 'prod_HoUUEvlnsVe9c5');
		end
	end
	def payment_method
		@price_id = params[:price_id]

		respond_to do |format|
			format.js { render '/subscriptions/js/payment_method' }
		end
	end

	def destroy
		begin
			subscription = Stripe::Subscription.update(params[:id], cancel_at_period_end: true)
		rescue Exception => e
			puts e
		end
		flash[:notice] = 'Plan successfully canceled.'
		redirect_to subscriptions_new_subscriptions_path
	end
end

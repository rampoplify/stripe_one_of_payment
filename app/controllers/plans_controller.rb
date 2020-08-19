class PlansController < ApplicationController
	def index
		begin
			
			@prices = Stripe::Price.list(product: 'prod_HoUUEvlnsVe9c5')
			subscription = Stripe::Customer.retrieve(current_user.customer_id).subscriptions
			@subscription_id = subscription.data[0].id
			if !subscription.data[0].cancel_at_period_end
				@upcoming_invoice = Stripe::Invoice.upcoming(:customer => current_user.customer_id)
			end
		rescue Exception => e
			flash[:notice] = 'There may be some stripe issue.'
			redirect_to root_path and return
		end
		
		@current_plan = subscription.data[0].plan if subscription.present?
		if !@current_plan.present?
			flash[:notice] = 'You dont have any active plan.'
			redirect_to subscriptions_new_subscriptions_path and return
		end
	end

	def show
		begin
			@upcoming_invoice = Stripe::Invoice.upcoming(:customer => current_user.customer_id)
		rescue Exception => e
			flash[:notice] = 'No Invoice found.'
		end
	end

	def update
		# customer_default_payment_method = Stripe::Customer.update( current_user.customer_id, invoice_settings: { default_payment_method: 'pm_1HFe26DvcWFPSGRTrGcW11y2' })
		begin
			subscription = Stripe::Subscription.retrieve(params[:subscription_id])
  			updated_subscription = Stripe::Subscription.update(params[:subscription_id], cancel_at_period_end: false, items: [ { id: subscription.items.data[0].id, price: params[:id] }], expand: %w[latest_invoice.payment_intent])
		rescue Exception => e
			flash[:notice] = 'Error while updating subscription.'
			redirect_to root_path and return
		end
		render json: {
			updated_subscription: updated_subscription
		}
	end

	def incoming_invoice
		subscription = Stripe::Subscription.retrieve(params[:subscription_id])
		next_invoice = Stripe::Invoice.upcoming(customer: current_user.customer_id, subscription: params[:subscription_id], subscription_items: [{ id: subscription.items.data[0].id, deleted: true }, { price: params[:id], deleted: false }] )
		
		render json: {
			next_invoice: next_invoice
		}
	end
end
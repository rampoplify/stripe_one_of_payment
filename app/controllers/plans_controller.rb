class PlansController < ApplicationController
	def index
		@prices = Stripe::Price.list(product: 'prod_HoUUEvlnsVe9c5')
		subscription = Stripe::Customer.retrieve(current_user.customer_id).subscriptions
		@current_plan = subscription.data[0].plan if subscription.present?
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
		subscription = Stripe::Subscription.retrieve(params[:subscription_id])
  		updated_subscription = Stripe::Subscription.update(params[:subscription_id], cancel_at_period_end: false, items: [ { id: subscription.items.data[0].id, price: params[:id] }], expand: %w[latest_invoice.payment_intent])
		render json: {
			updated_subscription: updated_subscription
		}
	end
end
class User < ApplicationRecord
	#Constants
	EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i

	# Callbacks
	before_create :create_stripe_customer

	# Validation
	validates_format_of   :email, with: EMAIL_REGEX
	validates_presence_of :name, :message => "can not be null"
	validates_presence_of :email, :message => "can not be null"
	validates_presence_of :contact_number, :message => "can not be null"
	validates_presence_of :password, :length => {:within => 8..40}, :message => "can not be null"

  	# Include default devise modules. Others available are:
  	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  	devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  	# Associations
  	has_many :user_cards
  	has_many :payment_details

    def create_stripe_customer
        begin
            customer = Stripe::Customer.create({ name: self.name, email: self.email })
            self.customer_id = customer.id
        rescue Exception => e
        	puts s
            # raise ActiveRecord::Rollback
            # throw :abort
        end  
    end
end

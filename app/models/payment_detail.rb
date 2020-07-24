class PaymentDetail < ApplicationRecord
  belongs_to :user

  validates :amount, presence: true
  validates :payment_intent, presence: true

end

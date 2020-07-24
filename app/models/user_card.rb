class UserCard < ApplicationRecord
  belongs_to :user

  validates :exp_month, presence: true
  validates :exp_year, presence: true
  validates :last_4, presence: true
  validates :card_type, presence: true
  validates :card_number, presence: true

end

class CreatePaymentDetails < ActiveRecord::Migration[6.0]
  def change
    create_table :payment_details do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount
      t.text :payment_intent

      t.timestamps
    end
  end
end

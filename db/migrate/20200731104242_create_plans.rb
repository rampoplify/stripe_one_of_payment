class CreatePlans < ActiveRecord::Migration[6.0]
  def change
    create_table :plans do |t|
      t.integer :amount
      t.text :currency
      t.text :name
      t.text :description
      t.string :interval
      t.integer :interval_count
      t.references :product, null: false, foreign_key: true
      t.text :stripe_prod_id

      t.timestamps
    end
  end
end

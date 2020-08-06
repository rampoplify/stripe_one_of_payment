class CreateProducts < ActiveRecord::Migration[6.0]
  def change
    create_table :products do |t|
      t.text :product_id
      t.text :name
      t.text :description

      t.timestamps
    end
  end
end

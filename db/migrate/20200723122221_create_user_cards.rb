class CreateUserCards < ActiveRecord::Migration[6.0]
  def change
    create_table :user_cards do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :exp_month
      t.integer :exp_year
      t.integer :last_4
      t.text :card_type
      t.text :card_number

      t.timestamps
    end
  end
end

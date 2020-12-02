class CreateFoodOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :food_orders do |t|
      t.integer :order_id
      t.integer :food_id
    end
  end
end

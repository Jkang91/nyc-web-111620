class AddOrderTotalToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :order_total, :float, default: 0
  end
end

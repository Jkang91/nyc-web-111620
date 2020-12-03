class Order < ActiveRecord::Base
    belongs_to :user
    has_many :food_orders
    has_many :foods, through: :food_orders

    def total_price
        self.foods.sum(:price)
    end

    def total_calories
        self.foods.sum(:calories)
    end
end
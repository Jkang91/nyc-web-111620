class Order < ActiveRecord::Base
    belongs_to :user
    has_many :food_orders
    has_many :foods, through: :food_orders

    def total_price
        total = self.foods.sum(:price)
        total.round(2)
    end

    def total_price_with_discount
        var = (total_price * 0.90)
        sprintf('%.2f', var)
    end

    def total_calories
        self.foods.sum(:calories)
    end
end
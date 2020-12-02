class Food < ActiveRecord::Base
    has_many :food_orders
end
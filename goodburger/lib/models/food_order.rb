class FoodOrder < ActiveRecord::Base
    belongs_to :order
    belongs_to :food
end
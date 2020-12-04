class User < ActiveRecord::Base
    has_many :orders

    def self.login_a_user
        puts "Welcome to Good Burger, Home of the Good Burger!"
        sleep 2
        puts "Let's log you in!"
        sleep 2
        puts "What is your username?"
        user_name = gets.chomp
        puts "What is your password?"
        pass = gets.chomp
        user = User.find_by(username: user_name, password: pass)
    end

    def self.register_a_user
        puts "Welcome to Good Burger, Home of the Good Burger!"
        sleep 2
        puts "Let's get you registered!"
        sleep 2
        puts "Please enter a username."
        user_name = gets.chomp
        puts "Please enter a password."
        pass = gets.chomp
        puts "Please enter your full name."
        full_name = gets.chomp
        user = User.find_by(username: user_name)
        if user
            puts "Sorry, but that username is already taken!"
            sleep 3
            system 'clear'
            self.register_a_user
        else
            User.create(username: user_name, password: pass, name: full_name)
            system 'clear'
            User.login_a_user
        end
    end

    # CREATE
    def add_food_to_current_order(food)
        FoodOrder.create(order: self.current_order, food: food)
    end

    
    #READ
    def past_orders
        self.orders.where(purchased: true)
    end

    def current_order
        orders.find_or_create_by(purchased: false)
    end

    def food_current_order
        current_order.food_orders.each do |food_order|
            puts "#{food_order.food.name} - $#{food_order.food.price}"
        end
    end

    def total_amount_spent_ever
        sum = 0
        self.past_orders.each do |past_order|
            sum += past_order.order_total
        end
        sum
    end

    def total_calories_consumed_ever
        sum = 0
        self.past_orders.each do |past_order|
            sum += past_order.total_calories
        end
        sum
    end

    def favorite_food
        array = self.past_orders.map {|past_order| past_order.foods}.flatten
        array_2 = array.map {|food| food.name}
        fav_food = array_2.max_by {|food| array_2.count(food)}
    end
    
    
    #UPDATE
    def purchase_current_order
        if rewards_member
            self.current_order.update(purchased: true, order_total: self.current_order.total_price_with_discount)
        else
            self.current_order.update(purchased: true, order_total: self.current_order.total_price)
        end
    end

    def make_rewards_member
        self.rewards_member = true
    end

    #DESTROY
    def cancel_current_order
        current_order.destroy
    end

    def remove_food_from_current_order(food_order_id)
        FoodOrder.destroy(food_order_id)
    end
end
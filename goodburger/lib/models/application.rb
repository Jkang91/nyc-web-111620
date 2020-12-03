class Application 
    attr_reader :prompt
    attr_accessor :user

    def initialize 
        @prompt = TTY::Prompt.new
    end

    def welcome
        puts "Welcome to Good Burger, Home of the Good Burger, Can I Take Your Order?"
    end

    def user_login_or_register
        prompt.select("Would you like to login or register?") do |menu|
            menu.choice "Register", -> {register_sequence}
            menu.choice "Login", -> {login_sequence}
            menu.choice "Exit", -> {exit_app}
        end
    end

   def login_sequence
    User.login_a_user
        if user.nil?
            prompt.select ("Would you like to register?") do |menu|
                menu.choice "Yes", -> {register_sequence}
                menu.choice "No", -> {exit_app}
            end
        end
   end
   
   def register_sequence
    User.register_a_user
   end

   def exit_app
    puts "Thanks for stopping by! See you next time!"
   end

   def main_menu
    user.reload
    system 'clear'
    prompt.select("Welcome, #{user.username}. What would you like to do?") do |menu|
        menu.choice "View Food Menu", -> {view_all_food}
        menu.choice "Add Food Item to Current Order", -> {add_food}
        menu.choice "View Current Order", -> {display_current_order}
        menu.choice "Cancel Orders", -> {cancel_order}
        menu.choice "User Stats", -> {user_stats}
        menu.choice "Exit", -> {exit_app}
        # menu.choice "", -> {}
        end
    end
    

    def view_all_food
        Food.all.each {|food| puts "#{food.name} - $#{food.price} - #{food.calories} cals"}
        prompt.select("") do |menu|
            menu.choice "Main Menu", -> {main_menu}
        end
    end

    def add_food
        prompt.select("Please select the food item you'd like to add to your order.") do |menu|
            menu.choice "#{Food.find(1).name} - $#{Food.find(1).price}", -> {add_food_sequence(Food.find(1))}
            menu.choice "#{Food.find(2).name} - $#{Food.find(2).price}", -> {add_food_sequence(Food.find(2))}
            menu.choice "#{Food.find(3).name} - $#{Food.find(3).price}", -> {add_food_sequence(Food.find(3))}
            menu.choice "#{Food.find(4).name} - $#{Food.find(4).price}", -> {add_food_sequence(Food.find(4))}
            menu.choice "Main Menu", -> {main_menu}
        end
    end

    def add_food_sequence(food)
        user.add_food_to_current_order(food)
        main_menu
    end

    def display_current_order  
        if user.current_order.foods == []
            puts "You have zero items in your current order." 
            puts "Please select 'Add Food Item to Current Order' to add items to your order."
            sleep 5
            main_menu
        else
            user.food_current_order
            if user.rewards_member || user.past_orders.length >= 10
                user.rewards_member = true
                puts "Congrats! As a Good Burger Rewards Member, you get 10% off all orders."
                puts "Your total amount is $#{(user.current_order.total_price * 0.90).round(2)}."
                prompt.select ("Would you like to place your order?") do |menu|
                    menu.choice "Yes", -> {purchasing_order}
                    menu.choice "No", -> {main_menu}
                end
            else
                puts "Your total amount is $#{user.current_order.total_price}."
                prompt.select ("Would you like to place your order?") do |menu|
                    menu.choice "Yes", -> {purchasing_order}
                    menu.choice "No", -> {main_menu}
                end
            end
        end
    end

    def purchasing_order
        user.purchase_current_order
        puts "Your order has been purchased!"
        sleep 5
        main_menu
    end
    
    def cancel_order
        prompt.select ("What would you like to cancel?") do |menu|
            menu.choice "Cancel entire order", -> {cancel_all_order}
            menu.choice "Remove item from order", -> {remove_item_sequence}
            menu.choice "Main Menu", -> {main_menu}
        end
    end

    def cancel_all_order
        user.cancel_current_order
        puts "Your order is now cancelled."
        sleep 5
        main_menu
    end

    def remove_item_sequence
        prompt.select ("Which food item would you like to remove?") do |menu|
            user.current_order.food_orders.select do |food_order|
                menu.choice "#{food_order.food.name}", -> {user.remove_food_from_current_order(food_order.id)}
            end
            menu.choice "exit", -> {main_menu}
        end
        main_menu
    end

    def user_stats
        puts "Your favorite food is #{user.favorite_food}!"
        puts "You have eaten #{user.total_calories_consumed_ever} total calories at Good Burger! Congrats, Fatty!"
        puts "I can't believe you've spent $#{user.total_amount_spent_ever.round(2)} at Good Burger all-time! Better take out a loan!"
        sleep 8
        main_menu
    end   
end 
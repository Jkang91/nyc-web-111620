class Application 
    attr_reader :prompt
    attr_accessor :user

    def initialize 
        @prompt = TTY::Prompt.new
    end
    
    def welcome
        ascii_helper("GoodBurger")
        sleep 2
        puts "Welcome to GoodBurger, Home of the GoodBurger!"
        sleep 3
    end

    def user_login_or_register
        system 'clear'
        ascii_helper("Welcome to GoodBurger")
        prompt.select(Rainbow("Would you like to login or register?").red) do |menu|
            menu.choice "Register", -> {register_sequence}
            menu.choice "Login", -> {login_sequence}
            menu.choice "Exit", -> {exit_app}
        end
    end

    def login_sequence
        system 'clear'
        ascii_helper("Login")
        user = User.login_a_user
        if user == nil
            puts "Sorry, username or password was incorrect."
            prompt.select (Rainbow("Would you like to try again or register?").red) do |menu|
                menu.choice "Try Again", -> {login_sequence}
                menu.choice "Register", -> {register_sequence}
                menu.choice "Exit", -> {exit_app}
            end
        else
            user
        end
    end
   
   def register_sequence
    system 'clear'
    ascii_helper("Register")
    User.register_a_user
    login_sequence
   end

   def exit_app
    system 'clear'
    puts "Thanks for stopping by GoodBurger! See you next time!"
    ascii_helper("GoodBurger")
   end

   def main_menu
    # user.reload
    system 'clear'
    ascii_helper("Welcome to GoodBurger")
    prompt.select(Rainbow("Welcome, #{user.username}. What would you like to do?").red) do |menu|
        menu.choice "View Food Menu", -> {view_all_food}
        menu.choice "Add Food Item to Current Order", -> {add_food}
        menu.choice "View Current Order", -> {display_current_order}
        menu.choice "Cancel Order", -> {cancel_order}
        menu.choice "Order History", -> {show_order_history}
        menu.choice "User Stats", -> {user_stats}
        menu.choice "Exit", -> {exit_app}
        end
    end
    

    def view_all_food
        system 'clear'
        ascii_helper("GoodBurger Menu")
        Food.all.each {|food| puts "#{food.name} - $#{food.price} - #{food.calories} cals"}
        prompt.select("") do |menu|
            menu.choice "Main Menu", -> {main_menu}
        end
    end

    def add_food
        system 'clear'
        ascii_helper("Welcome to GoodBurger")
        prompt.select(Rainbow("Welcome to GoodBurger, Home of the GoodBurger, Can I Take Your Order?").red) do |menu|
            menu.choice "Main Menu", -> {main_menu}
            Food.all.select do |food|
                menu.choice "#{food.name} - $#{food.price}", -> {add_food_sequence(food)}
            end
            menu.choice "Main Menu", -> {main_menu}
        end
    end

    def add_food_sequence(food)
        user.add_food_to_current_order(food)
        puts "You've added #{food.name} to your order."
        sleep 2
        add_food
    end

    def display_current_order
        system 'clear'
        ascii_helper("#{user.username}'s' Current Order")  
        if user.current_order.foods == []
            puts "You have zero items in your current order." 
            puts "Please select 'Add Food Item to Current Order' to add items to your order."
            prompt.select (" ") do |menu|
                menu.choice "Main Menu", -> {main_menu}
            end
        else
            user.food_current_order
            if user.rewards_member || user.past_orders.length >= 10
                user.rewards_member = true
                puts "Congrats! As a GoodBurger Rewards Member, you get 10% off all orders."
                puts "Your total amount is $#{user.current_order.total_price_with_discount}."
                prompt.select (Rainbow("Would you like to place your order?").red) do |menu|
                    menu.choice "Yes", -> {purchasing_order}
                    menu.choice "No", -> {main_menu}
                end
            else
                puts "Your total amount is $#{user.current_order.total_price}."
                prompt.select (Rainbow("Would you like to place your order?").red) do |menu|
                    menu.choice "Yes", -> {purchasing_order}
                    menu.choice "No", -> {main_menu}
                end
            end
        end
    end

    def purchasing_order
        system 'clear'
        ascii_helper("Purchase Order")
        user.purchase_current_order
        puts "Your order has been purchased!"
        sleep 5
        main_menu
    end
    
    def cancel_order
        system 'clear'
        ascii_helper("Cancel Order")
        prompt.select (Rainbow("What would you like to cancel?").red) do |menu|
            menu.choice "Cancel entire order", -> {cancel_all_order}
            menu.choice "Remove item from order", -> {remove_item_sequence}
            menu.choice "Main Menu", -> {main_menu}
        end
    end

    def cancel_all_order
        system 'clear'
        if user.current_order.food_orders.length == 0
            puts "You do not have a current order to cancel!"
            sleep 5
        else
            user.cancel_current_order
            puts "Your order is now cancelled."
            sleep 5 
        end
        main_menu
    end

    def remove_item_sequence
        system 'clear'
        if user.current_order.food_orders.length == 0
            puts "You have no items to remove!"
            sleep 5
        else
            prompt.select (Rainbow("Which food item would you like to remove?").red) do |menu|
                user.current_order.food_orders.select do |food_order|
                    menu.choice "#{food_order.food.name}", -> {user.remove_food_from_current_order(food_order.id)}
                end
                menu.choice "Main Menu", -> {main_menu}
            end
            puts "Your item has been removed."
            sleep 2
        end
        main_menu
    end

    def user_stat_message
        puts "Your favorite food is #{user.favorite_food}!"
        puts "You have eaten #{user.total_calories_consumed_ever} total calories at GoodBurger! Congrats, Fatty!"
        puts "I can't believe you've spent $#{user.total_amount_spent_ever.round(2)} at GoodBurger all-time! Better take out a loan!"
    end

    def user_stats
        system 'clear'
        ascii_helper("#{user.username}'s Stats")
        if user.past_orders.length == 0
            puts "Place an order to start seeing your Good Burger stats!"
        elsif user.rewards_member || user.past_orders.length > 10
            puts "You are a GoodBurger Rewards Member! Enjoy your 10% off all orders!"
            user_stat_message
        else
            user_stat_message
            user.orders_away_from_rewards
        end
        prompt.select (" ") do |menu|
            menu.choice "Main Menu", -> {main_menu}
        end
    end
    
    def show_order_history
        system 'clear'
        ascii_helper("#{user.username}'s Order History")
        if user.past_orders.length == 0
            puts "You've never ordered before!"
        else
            user.past_orders.each_with_index do |order, index|
                puts "Order: #{index + 1}"
                order.food_orders.each do |food_order|
                    puts "#{food_order.food.name} - $#{food_order.food.price}"
                end
                puts "Total: $#{order.order_total}"
                puts "----------"
            end
        end
        prompt.select (" ") do |menu|
            menu.choice "Main Menu", -> {main_menu}
        end
    end

    def ascii_helper(string)
        a = Artii::Base.new :font => 'slant'
        puts Rainbow(a.asciify(string)).yellow
    end
end 
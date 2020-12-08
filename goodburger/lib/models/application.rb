class Application 
    attr_reader :prompt
    attr_accessor :user

    def initialize 
        @prompt = TTY::Prompt.new
    end
    
    def welcome
        system 'clear'
        ascii_helper("GoodBurger")
        sleep 2
        puts Rainbow("Welcome to GoodBurger, Home of the GoodBurger!").orange
        sleep 3
    end

    def user_login_or_register
        system 'clear'
        ascii_helper("Welcome to GoodBurger")
        prompt.select(Rainbow("Would you like to login or register?").orange) do |menu|
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
            puts Rainbow("Sorry, username or password was incorrect.").orange
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
    puts Rainbow("Thanks for stopping by GoodBurger! See you next time!").orange
    ascii_helper("GoodBurger")
   end

   def main_menu
    # user.reload
    system 'clear'
    ascii_helper("Welcome to GoodBurger")
    prompt.select (Rainbow("Welcome, ").orange + Rainbow("#{user.username}.").red + Rainbow(" What would you like to do?").orange) do |menu|
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
        Food.all.each {|food| puts Rainbow("#{food.name}").orange + " - " + Rainbow("$#{food.price}").red + " - " + Rainbow("#{food.calories} cals").orange}
        # Food.all.each {|food| puts "#{food.name} - $#{food.price} - #{food.calories} cals"}
        prompt.select("") do |menu|
            menu.choice "Main Menu", -> {main_menu}
        end
    end

    def add_food
        system 'clear'
        ascii_helper("Welcome to GoodBurger")
        prompt.select(Rainbow("Welcome to GoodBurger, Home of the GoodBurger, Can I Take Your Order?").orange) do |menu|
            menu.choice "Main Menu", -> {main_menu}
            Food.all.select do |food|
                menu.choice Rainbow("#{food.name} - ").orange + Rainbow("$#{food.price}").red, -> {add_food_sequence(food)}
            end
            menu.choice "Main Menu", -> {main_menu}
        end
    end

    def add_food_sequence(food)
        user.add_food_to_current_order(food)
        puts Rainbow("You've added ").orange + Rainbow("#{food.name}").red + Rainbow(" to your order.").orange
        sleep 2
        add_food
    end

    def display_current_order
        system 'clear'
        ascii_helper("#{user.username}'s' Current Order")  
        if user.current_order.foods == []
            puts Rainbow("You have zero items in your current order.").orange
            puts Rainbow("Please select ").orange + Rainbow("Add Food Item to Current Order").red + Rainbow(" to add items to your order.").orange
            prompt.select (" ") do |menu|
                menu.choice "Main Menu", -> {main_menu}
            end
        else
            user.food_current_order
            if user.rewards_member || user.past_orders.length >= 10
                user.rewards_member = true
                puts Rainbow("Congrats! As a GoodBurger Rewards Member, you get ").orange + Rainbow("10% off all orders.").red
                puts Rainbow("Your total amount is ").orange + Rainbow("$#{user.current_order.total_price_with_discount}.").red
                prompt.select (Rainbow("Would you like to place your order?").orange) do |menu|
                    menu.choice "Yes", -> {purchasing_order}
                    menu.choice "No", -> {main_menu}
                end
            else
                puts Rainbow("Your total amount is ").orange + Rainbow("$#{user.current_order.total_price}.").red
                prompt.select (Rainbow("Would you like to place your order?").orange) do |menu|
                    menu.choice "Yes", -> {purchasing_order}
                    menu.choice "No", -> {main_menu}
                end
            end
        end
    end

    def purchasing_order
        system 'clear'
        ascii_helper("Order Confirmed")
        user.purchase_current_order
        puts Rainbow("Your order has been purchased! Enjoy!").orange
        sleep 5
        main_menu
    end
    
    def cancel_order
        system 'clear'
        ascii_helper("Cancel Order")
        prompt.select (Rainbow("What would you like to cancel?").orange) do |menu|
            menu.choice "Cancel entire order", -> {cancel_all_order}
            menu.choice "Remove item from order", -> {remove_item_sequence}
            menu.choice "Main Menu", -> {main_menu}
        end
    end

    def cancel_all_order
        system 'clear'
        if user.current_order.food_orders.length == 0
            puts Rainbow("You do not have a current order to cancel!").orange
            sleep 5
        else
            user.cancel_current_order
            puts Rainbow("Your order is now cancelled.").orange
            sleep 5 
        end
        main_menu
    end

    def remove_item_sequence
        system 'clear'
        if user.current_order.food_orders.length == 0
            puts Rainbow("You have no items to remove!").orange
            sleep 5
        else
            prompt.select (Rainbow("Which food item would you like to remove?").orange) do |menu|
                user.current_order.food_orders.select do |food_order|
                    menu.choice Rainbow("#{food_order.food.name}").orange, -> {user.remove_food_from_current_order(food_order.id)}
                end
                menu.choice "Main Menu", -> {main_menu}
            end
            puts Rainbow("Your item has been removed.").red
            sleep 2
        end
        main_menu
    end

    def user_stat_message
        puts Rainbow("Your favorite food is ").orange + Rainbow("#{user.favorite_food}!").red
        puts "-------"
        puts Rainbow("You have eaten ").orange + Rainbow("#{user.total_calories_consumed_ever}").red + Rainbow(" total calories at GoodBurger! Congrats, Fatty!").orange
        puts "-------"
        puts Rainbow("I can't believe you've spent ").orange + Rainbow("$#{user.total_amount_spent_ever.round(2)}").red + Rainbow(" at GoodBurger all-time! Better take out a loan!").orange
        puts "-------"
    end

    def user_stats
        system 'clear'
        ascii_helper("#{user.username}'s Stats")
        if user.past_orders.length == 0
            puts Rainbow("Place an order to start seeing your Good Burger stats!").orange
        elsif user.rewards_member || user.past_orders.length > 10
            puts Rainbow("You are a GoodBurger Rewards Member! Enjoy your ").orange + Rainbow("10% off all orders!").red
            puts "-------"
            user_stat_message
        else
            user.orders_away_from_rewards
            puts "-------"
            user_stat_message
        end
        prompt.select (" ") do |menu|
            menu.choice "Main Menu", -> {main_menu}
        end
    end
    
    def show_order_history
        system 'clear'
        ascii_helper("#{user.username}'s Order History")
        if user.past_orders.length == 0
            puts Rainbow("You've never ordered before!").orange
        else
            user.past_orders.each_with_index do |order, index|
                puts Rainbow("Order: #{index + 1}").orange
                order.food_orders.each do |food_order|
                    puts Rainbow("#{food_order.food.name} - $#{food_order.food.price}").red
                end
                puts Rainbow("Total: $#{sprintf('%.2f', order.order_total)}").orange
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
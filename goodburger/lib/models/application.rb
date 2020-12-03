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
        # menu.choice "", -> {}
        # menu.choice "", -> {}
        # menu.choice "", -> {}
        end
    end
    

    def view_all_food
        Food.all.each {|food| puts "#{food.name} - $#{food.price} - #{food.calories} cals"}
    end

    def add_food
        # user.reload
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
        user.food_current_order
        main_menu
    end
    
    def cancel_order
        prompt.select ("What would you like to cancel?") do |menu|
            menu.choice "Cancel entire order", -> {user.cancel_current_order}
            menu.choice "Remove item from order", -> {remove_item_sequence}
        end
    end

    def remove_item_sequence
        puts "Which item would you like to remove?"
        ans = gets.chomp
        user.remove_food_from_current_order(FoodOrder.all.find_by(food_id: Food.all.find_by(name: ans).id))
        main_menu
    end

        
end 
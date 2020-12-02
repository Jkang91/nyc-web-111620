june = User.create(username: "jk", password: "123", name: "June Kang")
ori = User.create(username: "om1188", password: "123", name: "Ori Markowitz")

hamburger = Food.create(name: "burger", price: 11.99, calories: 900)
pizza = Food.create(name: "pizza", price: 8.99, calories: 780)
fries = Food.create(name: "fries", price: 6.99, calories: 545)
milkshake = Food.create(name: "milkshake", price: 5.99, calories: 500)

past_order_1 = Order.create(user: june, purchased: true)
past_order_2 = Order.create(user: ori, purchased: true)

current_order_1 = Order.create(user: june)
current_order_2 = Order.create(user: ori)

past_food_order_1 = FoodOrder.create(order: past_order_1, food: hamburger)
past_food_order_2 = FoodOrder.create(order: past_order_2, food: hamburger)

current_food_order_1 = FoodOrder.create(order: current_order_1, food: pizza)
current_food_order_2 = FoodOrder.create(order: current_order_2, food: fries)

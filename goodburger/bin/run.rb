require_relative '../config/environment'

application = Application.new
application.welcome

# application.view_all_food


user_or_nil = application.user_login_or_register

application.user = user_or_nil

application.add_food

# until user_or_nil
#     system "clear"
#     user_or_nil = application.user_login_or_register
# end



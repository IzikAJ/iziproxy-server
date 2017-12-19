require "../config/db"
require "../app/models/*"
require "secure_random"

AuthToken.clear
User.clear
[
  "izikaj@gmail.com",
].each do |mail|
  pass = ENV["ENV"] == "development" ? "1" * 8 : SecureRandom.hex(16)
  user = User.build(email: mail, password: pass)
  user.log_requests = true
  if user.save
    puts "USER: #{mail}, #{pass}"
    auth = AuthToken.new(user_id: user.id)
    if auth.save
      puts "TOKEN: #{auth.token}"
    else
      puts "TOKEN ERRORS: #{auth.errors.inspect}"
    end
  else
    puts "USER ERRORS: #{user.errors.inspect}"
  end
end

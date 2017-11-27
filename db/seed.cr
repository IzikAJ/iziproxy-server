require "../app/models/*"
require "secure_random"

App::Models::AuthToken.clear
App::Models::User.clear
[
  "izikaj@gmail.com",
].each do |mail|
  pass = SecureRandom.hex(16)
  user = App::Models::User.build(email: mail, password: pass)
  user.save
  auth = App::Models::AuthToken.create(user_id: user.id)
  puts "USER: #{mail}, #{pass}"
  puts "TOKEN: #{auth.token}"
end

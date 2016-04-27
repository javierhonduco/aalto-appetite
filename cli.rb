require './app.rb'

puts get_menu((ARGV.first || 'alvari').to_sym)

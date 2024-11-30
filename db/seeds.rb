# Liste des options disponibles
options = %w[smallNestedGraph BigFlatGraph]

# Affiche les options
puts "Available options in db/seeds/school:"
options.each_with_index { |option, index| puts "#{index + 1}. #{option}" }

# Demande à l'utilisateur de choisir une option
print "Choose an option (number): "
choice = gets.chomp.to_i

# Vérifie le choix et exécute la seed correspondante
if choice.between?(1, options.length)
  selected_option = options[choice - 1]
  seed_file = File.join(__dir__, 'seeds', 'school', selected_option, 'seed.rb')
  puts "Running #{seed_file}..."
  load seed_file
else
  puts "Invalid choice. Exiting."
end



# Load seed files in order of dependency
# 1. Load base concepts and shared atoms first
require_relative 'seeds/students'

# 2. Load skill ontology that builds on base concepts
require_relative 'seeds/skills'

# 3. Load session data that uses concepts from both
require_relative 'seeds/thp_sessions'

puts "Seeding completed!"

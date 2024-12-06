puts "Starting stress test seed generation..."

# Constants
NODE_COUNT = 20000
LINK_COUNT = 1000
CREATOR_LABEL = "Stress Test Generator"

# Creator
creator = Creator.find_or_create_by!(label: CREATOR_LABEL) do |c|
  c.image = "stress_test.png"
end

# Generate Nodes (Atoms)
nodes = []
NODE_COUNT.times do |i|
  label = "Node #{i + 1}"
  nodes << Atom.find_or_create_by!(label: label) do |atom|
    atom.creator = creator
  end
end

puts "Generated #{nodes.size} nodes."

# Generate Links (Triples)
predicates = ["is part of", "requires", "teaches", "follows", "includes"]

LINK_COUNT.times do
  begin
    subject = nodes.sample
    predicate_label = predicates.sample
    object = nodes.sample

    next if subject == object # Avoid self-loops

    predicate = Atom.find_or_create_by!(label: predicate_label) do |atom|
      atom.creator = creator
    end

    Triple.create!(
      subject: subject,
      predicate: predicate,
      object: object,
      creator: creator
    )
  rescue ActiveRecord::RecordInvalid => e
    puts "Error creating triple: #{e.message}"
  end
end

puts "Generated #{LINK_COUNT} links."
puts "Stress test seed generation completed!"

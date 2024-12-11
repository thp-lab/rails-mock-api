require 'csv'

# Create system creator
puts "Creating system creator..."
Creator.create!(
  label: 'system',
  image: 'system.png'
)

puts "Importing atoms from CSV..."
CSV.foreach(Rails.root.join('db/seeds/atoms.csv'), headers: true) do |row|
  Atom.create!(
    label: row['name'],
    creator_label: 'system',
    metadata: {
      '@context': row['@context'],
      '@type': row['@type'],
      'url': row['url'],
      'description': row['description'],
      'image': row['image']
    }
  )
end

puts "Importing triples from CSV..."
CSV.foreach(Rails.root.join('db/seeds/triples.csv'), headers: true) do |row|
  Triple.create!(
    id: row['id'],
    subject_type: row['subject_type'],
    subject_id: row['subject_id'],
    predicate_type: row['predicate_type'],
    predicate_id: row['predicate_id'],
    object_type: row['object_type'],
    object_id: row['object_id'],
    creator_label: row['creator_label'],
    created_at: row['created_at'],
    updated_at: row['updated_at']
  )
end

puts "Seed completed successfully!"

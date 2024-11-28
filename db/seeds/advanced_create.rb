# Import des méthodes utilitaires
require_relative 'create'

# Méthode utilitaire améliorée pour créer des atomes avec métadonnées
def create_atom_with_metadata(label, creator, metadata = {})
  atom = find_or_create_atom(label, creator.label, creator)
  metadata.each do |key, value|
    metadata_atom = find_or_create_atom(value.to_s, creator.label, creator)
    create_triple(atom, find_or_create_atom(key.to_s, creator.label, creator), metadata_atom, creator)
  end
  atom
end

# Méthode pour créer des chaînes de relations
def create_relation_chain(atoms, relation_type, creator, bidirectional: false)
  atoms.each_cons(2) do |current, next_atom|
    create_triple(current, relation_type, next_atom, creator)
    create_triple(next_atom, relation_type, current, creator) if bidirectional
  end
end

# Méthode pour créer des relations imbriquées
def create_nested_relations(parent, children, relation_type, creator, depth = 0, max_depth = 3)
  return if depth >= max_depth
  
  children.each do |child|
    create_triple(parent, relation_type, child, creator)
    
    # Création de sous-relations
    sub_children = Array.new(rand(2..4)) do
      create_atom_with_metadata(
        "#{child.label}_sub_#{Faker::Lorem.word}",
        creator,
        {
          level: depth + 1,
          category: Faker::Lorem.word
        }
      )
    end
    
    create_nested_relations(child, sub_children, relation_type, creator, depth + 1, max_depth)
  end
end

# Création du créateur principal
creator = Creator.find_or_create_by!(label: 'The Hacking Project', image: 'thp_logo.png')

# Création des atomes principaux basés sur l'image
atoms = %w[Element1 Element2 Element3 Element4 Element5].map do |label|
  create_atom_with_metadata(label, creator, {
    type: Faker::Lorem.word,
    category: Faker::Lorem.word,
    status: %w[active pending completed][rand(3)]
  })
end

# Création des relations de base entre les éléments (comme montré dans l'image)
connected_to = find_or_create_atom('connected_to', creator.label, creator)
create_relation_chain(atoms, connected_to, creator)

# Création de relations imbriquées pour chaque élément
atoms.each do |atom|
  # Création de sous-éléments
  sub_elements = Array.new(rand(3..5)) do
    create_atom_with_metadata(
      "sub_#{atom.label}_#{Faker::Lorem.word}",
      creator,
      {
        parent: atom.label,
        type: Faker::Lorem.word
      }
    )
  end
  
  # Création de relations imbriquées
  has_component = find_or_create_atom('has_component', creator.label, creator)
  create_nested_relations(atom, sub_elements, has_component, creator)
  
  # Création de relations croisées entre sous-éléments
  relates_to = find_or_create_atom('relates_to', creator.label, creator)
  sub_elements.combination(2).each do |elem1, elem2|
    if rand < 0.3 # 30% de chance de créer une relation croisée
      create_triple(elem1, relates_to, elem2, creator)
    end
  end
end

# Création de métadonnées supplémentaires pour enrichir les relations
atoms.each do |atom|
  # Ajout de propriétés temporelles
  created_at = find_or_create_atom('created_at', creator.label, creator)
  updated_at = find_or_create_atom('updated_at', creator.label, creator)
  
  create_triple(atom, created_at, 
    find_or_create_atom(Time.now.strftime("%Y-%m-%d"), creator.label, creator),
    creator)
  create_triple(atom, updated_at,
    find_or_create_atom(Time.now.strftime("%Y-%m-%d %H:%M"), creator.label, creator),
    creator)
end

puts "Création terminée avec succès!"
puts "Nombre total d'atomes créés: #{Atom.count}"
puts "Nombre total de relations créées: #{Triple.count}"

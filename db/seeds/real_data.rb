require 'faker'

# Méthode utilitaire pour trouver ou créer un atome
def find_or_create_atom(label, creator_label, creator)
  Atom.find_by(label: label, creator_label: creator_label) ||
    Atom.create!(label: label, creator_label: creator_label, creator: creator)
end

# Méthode utilitaire pour créer des triples de manière sécurisée
def create_triple(subject, predicate, object, creator)
  object_atom = object.is_a?(String) ? find_or_create_atom(object, creator.label, creator) : object
  Triple.find_by(subject: subject, predicate: predicate, object: object_atom, creator: creator) ||
    Triple.create!(subject: subject, predicate: predicate, object: object_atom, creator: creator)
end

# Méthode pour créer un triplet sur un triplet
def create_nested_triple(inner_subject, inner_predicate, inner_object, outer_predicate, outer_object, creator)
  inner_triple = create_triple(inner_subject, inner_predicate, inner_object, creator)
  create_triple(inner_triple, outer_predicate, outer_object, creator)
end

# Création du créateur principal
creator = Creator.find_or_create_by!(label: 'The Hacking Project', image: 'thp_logo.png')

# Création des prédicats communs
est = find_or_create_atom('est', creator.label, creator)
propose = find_or_create_atom('propose', creator.label, creator)
inclut = find_or_create_atom('inclut', creator.label, creator)
utilise = find_or_create_atom('utilise', creator.label, creator)
appartient_a = find_or_create_atom('appartient à', creator.label, creator)
enseigne = find_or_create_atom('enseigne', creator.label, creator)
developpe = find_or_create_atom('développe', creator.label, creator)

# Création des entités principales
thp = find_or_create_atom('THP', creator.label, creator)
formation_backend = find_or_create_atom('Formation Backend', creator.label, creator)
formation_frontend = find_or_create_atom('Formation Frontend', creator.label, creator)
formation_fullstack = find_or_create_atom('Formation Fullstack', creator.label, creator)

# Technologies
postgresql = find_or_create_atom('PostgreSQL', creator.label, creator)
javascript = find_or_create_atom('JavaScript', creator.label, creator)
ruby_on_rails = find_or_create_atom('Ruby on Rails', creator.label, creator)
react = find_or_create_atom('React', creator.label, creator)
html = find_or_create_atom('HTML', creator.label, creator)
css = find_or_create_atom('CSS', creator.label, creator)

# Formation Backend et ses technologies
create_nested_triple(
  formation_backend, utilise, postgresql,
  appartient_a, thp,
  creator
)

create_nested_triple(
  formation_backend, utilise, ruby_on_rails,
  appartient_a, thp,
  creator
)

# Formation Frontend et ses technologies
create_nested_triple(
  formation_frontend, utilise, html,
  appartient_a, thp,
  creator
)

create_nested_triple(
  formation_frontend, utilise, css,
  appartient_a, thp,
  creator
)

create_nested_triple(
  formation_frontend, utilise, javascript,
  appartient_a, thp,
  creator
)

# Formation Fullstack et ses technologies
create_nested_triple(
  formation_fullstack, utilise, javascript,
  appartient_a, thp,
  creator
)

create_nested_triple(
  formation_fullstack, utilise, ruby_on_rails,
  appartient_a, thp,
  creator
)

create_nested_triple(
  formation_fullstack, utilise, react,
  appartient_a, thp,
  creator
)

# Projets
projet_rails_api = find_or_create_atom('Projet Rails API', creator.label, creator)

create_nested_triple(
  projet_rails_api, utilise, postgresql,
  appartient_a, formation_backend,
  creator
)

create_nested_triple(
  projet_rails_api, utilise, ruby_on_rails,
  appartient_a, formation_backend,
  creator
)

# Relations d'enseignement
create_nested_triple(
  thp, enseigne, javascript,
  appartient_a, formation_fullstack,
  creator
)

create_nested_triple(
  thp, enseigne, ruby_on_rails,
  appartient_a, formation_fullstack,
  creator
)

create_nested_triple(
  thp, enseigne, postgresql,
  appartient_a, formation_backend,
  creator
)

# Relations de développement
api_rest = find_or_create_atom('API REST', creator.label, creator)

create_nested_triple(
  projet_rails_api, developpe, api_rest,
  appartient_a, formation_backend,
  creator
)

puts "Création des triplets imbriqués terminée avec succès!"
puts "Nombre total d'atomes créés: #{Atom.count}"
puts "Nombre total de relations créées: #{Triple.count}"

require 'faker'

# Méthode utilitaire pour trouver ou créer un atome
def find_or_create_atom(label, creator_label, creator)
  Atom.find_by(label: label, creator_label: creator_label) ||
    Atom.create!(label: label, creator_label: creator_label, creator: creator)
end

# Méthode utilitaire pour créer des triples de manière sécurisée
def create_triple(subject, predicate, object, creator)
  Triple.find_by(subject: subject, predicate: predicate, object: object, creator: creator) ||
    Triple.create!(subject: subject, predicate: predicate, object: object, creator: creator)
end

# Création du créateur principal
creator = Creator.find_or_create_by!(label: 'The Hacking Project', image: 'thp_logo.png')

# Concepts de base
is_a = find_or_create_atom('is a', creator.label, creator)
has_session = find_or_create_atom('has session', creator.label, creator)
enrolled_in = find_or_create_atom('enrolled in', creator.label, creator)
completed = find_or_create_atom('completed', creator.label, creator)
followed_by = find_or_create_atom('followed by', creator.label, creator)

# Entités
school = find_or_create_atom('School', creator.label, creator)
session = find_or_create_atom('Session', creator.label, creator)
student = find_or_create_atom('Student', creator.label, creator)

# Étapes du parcours
introduction = find_or_create_atom('Introduction', creator.label, creator)
fullstack = find_or_create_atom('Fullstack', creator.label, creator)
developer = find_or_create_atom('Developer', creator.label, creator)
developer_plus = find_or_create_atom('Developer++', creator.label, creator)

# Lier THP à l'entité "School"
create_triple(creator, is_a, school, creator)

# Créer les sessions
sessions = []
12.downto(1) do |i|
  month = (Date.today - i.months).strftime('%B %Y')
  session_atom = find_or_create_atom("Session #{month}", creator.label, creator)
  sessions << session_atom

  create_triple(creator, has_session, session_atom, creator)
end

# Lier les étapes du parcours
[[introduction, fullstack], [fullstack, developer], [developer, developer_plus]].each do |current, next_stage|
  create_triple(current, followed_by, next_stage, creator)
end

# Créer 100 étudiants
100.times do |i|
  first_name = Faker::Name.unique.first_name
  last_name = Faker::Name.unique.last_name
  full_name = "#{first_name} #{last_name}"

  student_atom = find_or_create_atom(full_name, creator.label, creator)
  student_creator = Creator.find_or_create_by!(label: full_name, image: Faker::Avatar.image(slug: full_name, size: '100x100', format: 'png'))

  create_triple(student_atom, is_a, student, student_creator)

  # Assigner une session pondérée
  session_index = (rand ** 2 * sessions.length).to_i
  student_session = sessions[session_index]

  create_triple(student_atom, enrolled_in, student_session, student_creator)

  # Étapes de progression
  create_triple(student_atom, completed, introduction, student_creator)

  if rand < 0.7
    create_triple(student_atom, completed, fullstack, student_creator)

    if rand < 0.5
      create_triple(student_atom, completed, developer, student_creator)

      if rand < 0.3
        create_triple(student_atom, completed, developer_plus, student_creator)
      end
    end
  end

  puts "Créé étudiant #{i + 1} : #{full_name}" if (i + 1) % 10 == 0
end

puts 'Seeding terminé avec succès !'
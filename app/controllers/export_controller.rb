require 'csv'

class ExportController < ApplicationController
  def csv
    # Détermine quel fichier CSV doit être généré en fonction du paramètre
    if params[:type] == 'atoms'
      csv_data = generate_atoms_csv
      filename = 'atoms.csv'
    else
      csv_data = generate_triples_csv
      filename = 'triples.csv'
    end
    
    # Envoie le fichier CSV directement
    send_data(csv_data, filename: filename, type: 'text/csv')
  end

  private

  def generate_atoms_csv
    CSV.generate(headers: true) do |csv|
      # En-têtes pour atoms.csv
      csv << %w[@context @type name url description image]

      # Utilise les metadata stockées dans les atoms, en excluant ceux de type Triple
      Atom.includes(:creator).find_each do |atom|
        next if atom.metadata&.dig('@type') == 'Triple'

        csv << [
          atom.metadata['@context'] || 'https://schema.org',
          atom.metadata['@type'] || 'Organization',
          atom.label,
          atom.metadata['url'] || '',
          atom.metadata['description'] || '',
          atom.metadata['image'] || ''
        ]
      end
    end
  end

  def generate_triples_csv
    CSV.generate(headers: true) do |csv|
      # En-têtes pour triples.csv
      csv << %w[id subject_type subject_id predicate_type predicate_id object_type object_id creator_label created_at updated_at]

      # Ajoute les données des triples
      Triple.find_each do |triple|
        csv << [
          triple.id,
          triple.subject_type,
          triple.subject_id,
          triple.predicate_type,
          triple.predicate_id,
          triple.object_type,
          triple.object_id,
          triple.creator_label,
          triple.created_at,
          triple.updated_at
        ]
      end
    end
  end
end

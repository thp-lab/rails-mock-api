require 'csv'
require 'zip'

class ExportController < ApplicationController
  def csv
    # Crée un fichier ZIP temporaire contenant les deux CSV
    temp_file = Tempfile.new('export.zip')
    
    begin
      Zip::OutputStream.open(temp_file) { |zos| }  # Initialise le ZIP
      
      Zip::File.open(temp_file.path, Zip::File::CREATE) do |zipfile|
        # Ajoute le fichier atoms.csv
        zipfile.get_output_stream("atoms.csv") do |f|
          f.write(generate_atoms_csv)
        end
        
        # Ajoute le fichier triples.csv
        zipfile.get_output_stream("triples.csv") do |f|
          f.write(generate_triples_csv)
        end
      end
      
      # Envoie le fichier ZIP
      zip_data = File.read(temp_file.path)
      send_data(zip_data, filename: "export.zip", type: 'application/zip')
    ensure
      temp_file.close
      temp_file.unlink
    end
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

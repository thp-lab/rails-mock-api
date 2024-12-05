require 'csv'

class ExportController < ApplicationController
  def csv
    data = generate_csv_data
    send_data data, filename: "schema_export.csv", type: "text/csv"
  end

  private

  def generate_csv_data
    CSV.generate(headers: true) do |csv|
      # En-têtes selon le format schema.org
      csv << %w[@context @type name url description image]

      # Utilise les metadata stockées dans les atoms
      Atom.includes(:creator).find_each do |atom|
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
end

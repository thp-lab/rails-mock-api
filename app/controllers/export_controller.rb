require 'csv'

class ExportController < ApplicationController
  def csv
    data = generate_csv_data
    send_data data, filename: "data.csv", type: "text/csv"
  end

  private

  def generate_csv_data
    CSV.generate(headers: true) do |csv|
      # CSV Headers
      csv << %w[id subject_type subject_id predicate_type predicate_id object_type object_id creator_label created_at updated_at]

      # Add the triples data
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

class AddMetadataToAtoms < ActiveRecord::Migration[7.0]
  def change
    add_column :atoms, :metadata, :jsonb, default: {}, null: false
    add_index :atoms, :metadata, using: :gin
  end
end

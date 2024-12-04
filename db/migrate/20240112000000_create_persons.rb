class CreatePersons < ActiveRecord::Migration[7.0]
  def change
    create_table :persons, id: false do |t|
      t.string :label, null: false
      t.string :name
      t.string :url
      t.text :description
      t.string :image
      t.string :context

      t.timestamps
    end

    add_index :persons, :label, unique: true
  end
end

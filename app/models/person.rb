class Person < ApplicationRecord
  self.table_name = "persons"
  self.primary_key = "label"

  # For use in triples
  has_many :asSubject, as: :subject, class_name: "Triple"
  has_many :asPredicate, as: :predicate, class_name: "Triple"
  has_many :asObject, as: :object, class_name: "Triple"

  def label
    name
  end
end

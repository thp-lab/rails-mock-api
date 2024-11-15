class Atom < ApplicationRecord
  self.primary_key = "label"

  belongs_to :creator, primary_key: "label", foreign_key: "creator_label"

  # Polymorphic relationships for triples
  has_many :asSubject, as: :subject, class_name: "Triple"
  has_many :asPredicate, as: :predicate, class_name: "Triple"
  has_many :asObject, as: :object, class_name: "Triple"

  validates :label, presence: true
end

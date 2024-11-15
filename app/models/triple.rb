class Triple < ApplicationRecord
  self.primary_key = "id"

  belongs_to :creator, primary_key: "label", foreign_key: "creator_label"

  # Polymorphic relationships for components
  belongs_to :subject, polymorphic: true
  belongs_to :predicate, polymorphic: true
  belongs_to :object, polymorphic: true

  # Polymorphic relationships for being used in other triples
  has_many :asSubject, as: :subject, class_name: "Triple"
  has_many :asPredicate, as: :predicate, class_name: "Triple"
  has_many :asObject, as: :object, class_name: "Triple"

  # Computed ID based on components
  before_validation :set_computed_id

  private

  def set_computed_id
    self.id = "#{subject.label} #{predicate.label} #{object.label}"
  end
end

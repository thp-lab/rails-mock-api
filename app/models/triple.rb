class Triple < ApplicationRecord
  self.primary_key = "id"

  belongs_to :creator, primary_key: "label", foreign_key: "creator_label"

  # Polymorphic relationships for components
  belongs_to :subject, polymorphic: true, optional: true
  belongs_to :predicate, polymorphic: true, optional: true
  belongs_to :object, polymorphic: true, optional: true

  # Polymorphic relationships for being used in other triples
  has_many :asSubject, as: :subject, class_name: "Triple"
  has_many :asPredicate, as: :predicate, class_name: "Triple"
  has_many :asObject, as: :object, class_name: "Triple"

  # Computed ID based on components
  before_validation :set_computed_id
  validates :id, uniqueness: { message: "This triplet already exists" }

  # Label method for when Triple is used as a component
  def label
    id.gsub('_', ' ')
  end

  private

  def set_computed_id
    subject_label = get_component_label(subject_type, subject_id)
    predicate_label = get_component_label(predicate_type, predicate_id)
    object_label = get_component_label(object_type, object_id)
    
    self.id = "#{subject_label} #{predicate_label} #{object_label}"
  end

  def get_component_label(type, id)
    return id unless type.present?
    
    # Handle Triple type separately since it uses 'id' instead of 'label'
    if type == "Triple"
      triple = Triple.find_by(id: id)
      return triple&.id || id
    end
    
    # Try to find the component in Atom table first
    atom = Atom.find_by(label: id)
    return atom.label if atom.present?

    # If not found in Atom, try to find in the specific type's table
    begin
      component = type.constantize.find_by(label: id)
      component&.label || id
    rescue NameError
      id
    end
  end
end

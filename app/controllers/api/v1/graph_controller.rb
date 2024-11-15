class Api::V1::GraphController < ApplicationController
  def index
    atoms = Atom.all.map do |atom|
      {
        id: atom.label,
        label: atom.label,
        creator: atom.creator.label
      }
    end

    triples = Triple.all.map do |triple|
      {
        id: triple.id,
        subject: {
          id: triple.subject.label,
          type: triple.subject_type
        },
        predicate: {
          id: triple.predicate.label,
          type: triple.predicate_type
        },
        object: {
          id: triple.object.label,
          type: triple.object_type
        },
        creator: triple.creator.label
      }
    end

    render json: {
      atoms: atoms,
      triples: triples
    }
  end
end

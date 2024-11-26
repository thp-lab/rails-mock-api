class Api::V1::GraphController < ApplicationController
  def index
    render_graph_data
  end

  def create
    render_graph_data
  end

  private

  def render_graph_data
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
        label: triple.id,
        subject: {
          id: triple.subject.label,
          label: triple.subject.label,
          type: triple.subject_type
        },
        predicate: {
          id: triple.predicate.label,
          label: triple.predicate.label,
          type: triple.predicate_type
        },
        object: {
          id: triple.object.label,
          label: triple.object.label,
          type: triple.object_type
        },
        creator: triple.creator.label
      }
    end

    render json: {
      data: {
        triples: triples
      }

    }
  end
end

class TripleController < ApplicationController
  def index
    render_graph_data
  end

  def create
    triple = Triple.new(triple_params)
    if triple.save
      render json: { data: { triple: triple } }, status: :created
    else
      render json: { error: triple.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def triple_params
    params.require(:triple).permit(:subject_label, :predicate_label, :object_label)
  end

  def render_graph_data
    triples = Triple.includes(:subject, :predicate, :object, :creator).map do |triple|
      {
        id: triple.id,
        label: triple.label,
        type: 'Triple',
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

    atoms = Atom.includes(:creator).map do |atom|
      {
        id: atom.label,
        label: atom.label,
        type: 'Atom'
      }
    end

    @atoms = {
      data: {
        atoms: atoms + triples
      }
    }
    render 'triple/index'
  end
end

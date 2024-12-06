class TripleController < ApplicationController
  def index
    render_graph_data
  end

  def create
    begin
      creator = Creator.find_or_create_by!(
        label: 'The Hacking Project',
        image: 'thp_logo.png'
      )

      subject = Atom.where(label: triple_params[:subject_label]).first_or_initialize.tap do |atom|
        atom.creator = creator
        atom.save!
      end

      predicate = Atom.where(label: triple_params[:predicate_label]).first_or_initialize.tap do |atom|
        atom.creator = creator
        atom.save!
      end

      object = Atom.where(label: triple_params[:object_label]).first_or_initialize.tap do |atom|
        atom.creator = creator
        atom.save!
      end

      triple = Triple.create!(
        subject: subject,
        predicate: predicate,
        object: object,
        creator: creator
      )

      render json: { data: { triple: triple } }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { error: e.message }, status: :internal_server_error
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

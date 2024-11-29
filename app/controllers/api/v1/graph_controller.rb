class Api::V1::GraphController < Api::BaseController
  def index
    render_graph_data
  end

  def create
    begin
      creator = Creator.find_or_create_by!(
        label: 'The Hacking Project',
        image: 'thp_logo.png'
      )

      subject = Atom.find_or_create_by!(
        label: triple_params[:subject_label],
        creator_label: creator.label,
        creator: creator
      )

      predicate = Atom.find_or_create_by!(
        label: triple_params[:predicate_label],
        creator_label: creator.label,
        creator: creator
      )

      object = Atom.find_or_create_by!(
        label: triple_params[:object_label],
        creator_label: creator.label,
        creator: creator
      )

      triple = Triple.create!(
        subject: subject,
        predicate: predicate,
        object: object,
        creator: creator
      )

      render_graph_data
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: "Erreur de validation: #{e.message}" }, status: :unprocessable_entity
    rescue StandardError => e
      render json: { error: "Une erreur est survenue: #{e.message}" }, status: :internal_server_error
    end
  end

  private

  def triple_params
    params.require(:triple).permit(:subject_label, :predicate_label, :object_label)
  end

  def render_graph_data
    triples = Triple.all.map do |triple|
      {
        id: triple.id,
        label: triple.id,
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

    atoms = Atom.all.map do |atom|
      {
        id: atom.label,
        label: atom.label,
        type: 'Atom'
      }
    end

    render json: {
      data: {
        atoms: atoms + triples
      }
    }
  end
end

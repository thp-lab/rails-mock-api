class NlpController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:generate]

  def generate
    prompt = params[:prompt]

    api_key = ENV["OPENAI_API_KEY"]
    if api_key.nil? || api_key.empty?
      render json: { error: "API key missing in environment variables" }, status: :unprocessable_entity
      return
    end

    Rails.logger.debug "Reçu un prompt pour génération : #{prompt}"

    # Appel au service pour générer les triples et le texte enrichi
    nlp_service = NlpService.new(api_key)
    result = nlp_service.generate_triples_and_text(prompt)

    Rails.logger.debug "Résultat obtenu après génération : #{result.inspect}"

    render json: result
  rescue StandardError => e
    Rails.logger.error "Erreur dans le NlpController : #{e.message}"
    render json: { error: e.message }, status: :unprocessable_entity
  end
end

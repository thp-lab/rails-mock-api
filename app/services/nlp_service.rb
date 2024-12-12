# app/services/nlp_service.rb
class NlpService
  require 'openai' # Si tu utilises OpenAI, configure la gem correspondante.

  def initialize(api_key)
    @client = OpenAI::Client.new(access_token: api_key)
  end

  def generate_triples_and_text(prompt)
    # Appel à l'API NLP pour obtenir des résultats.
    response = @client.chat(
      parameters: {
        model: "gpt-4", # Choisir un modèle pertinent
        messages: [{ role: "user", content: prompt }],
        max_tokens: 500
      }
    )
    output = response.dig("choices", 0, "message", "content")
    parse_output(output)
  end

  private

  def parse_output(output)
    # Supposons que l'output inclut des triples RDF formatés.
    data = JSON.parse(output) # Par exemple, convertir en hash si nécessaire
    {
      triples: data["triples"], # Liste des triples RDF
      enriched_text: data["enriched_text"] # Texte enrichi
    }
  rescue JSON::ParserError
    raise "Erreur lors de l'analyse de la sortie NLP."
  end
end

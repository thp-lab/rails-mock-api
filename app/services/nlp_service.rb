class NlpService
  MAX_RETRIES = 3  # Nombre maximal de tentatives

  def initialize(api_key)
    raise "API key is missing" if api_key.nil? || api_key.empty?

    @client = OpenAI::Client.new(access_token: api_key)
  end

  def generate_triples_and_text(prompt)
    retries = 0

    begin
      response = @client.completions(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [
            { role: "system", content: "You are a helpful assistant." },
            { role: "user", content: prompt }
          ],
          max_tokens: 500
        }
      )

      # Vérification de la réponse
      if response['error']
        raise "OpenAI Error: #{response['error']['message']}"
      end

      output = response.dig("choices", 0, "message", "content")
      parse_output(output)

    rescue => e
      if e.message.include?('429') && retries < MAX_RETRIES
        retries += 1
        Rails.logger.warn "Rate limit exceeded, retrying in 10 seconds... (Attempt ##{retries})"
        sleep(10)  # Attente de 10 secondes avant de réessayer
        retry
      else
        Rails.logger.error "Error from OpenAI API: #{e.message}"
        raise "Erreur avec l'API OpenAI : #{e.message}"
      end
    end
  end

  private

  def parse_output(output)
    begin
      data = JSON.parse(output)
      {
        triples: data["triples"],
        enriched_text: data["enriched_text"]
      }
    rescue JSON::ParserError => e
      raise "Erreur lors de l'analyse de la sortie NLP. Détails: #{e.message}"
    end
  end
end

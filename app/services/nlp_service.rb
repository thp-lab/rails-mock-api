require "http"
require "json"

class NlpService
  def initialize(api_key)
    raise "API key is missing" if api_key.nil? || api_key.empty?

    @api_key = api_key
    @url = "https://api.openai.com/v1/chat/completions"  # Utilisation de l'endpoint chat/completions
  end

  def generate_triples_and_text(prompt)
    begin
      # Préparation de la requête à OpenAI via HTTP
      headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@api_key}"
      }

      # Structure du message pour l'API chat/completions
      data = {
        model: "gpt-3.5-turbo",  # Le modèle utilisé
        messages: [
          {
            role: "system",
            content: <<~SYSTEM
              Vous êtes un assistant IA spécialisé dans la génération de triples RDF à partir de descriptions textuelles. Votre tâche consiste à analyser un texte et à extraire les triples RDF au format suivant :
{ "subject": "<sujet>", "predicate": "<prédicat>", "object": "<objet>" }.

Cependant, certains sujets, prédicats ou objets dans un triple peuvent eux-mêmes être des triples imbriqués. Vous devez les traiter de manière récursive, où un triple peut contenir un autre triple en tant qu'objet, sujet ou prédicat.

Vous devez également produire une interprétation textuelle de la sémantique des triples précédemment créés, en les structurant pour en faire une recommandation claire, concise.

**Exemple :**
Texte d'entrée :
"L'étudiant Jean Dupont a complété avec succès le programme Python intensif de THP. Il a démontré une maîtrise exceptionnelle du langage, en résolvant des problèmes complexes et en développant des projets ambitieux."

**Résultat attendu :**

**1. Triples RDF**
```json
[
  { "subject": "Jean Dupont", "predicate": "a complété", "object": "Programme Python intensif de THP" },
  { "subject": "Jean Dupont", "predicate": "a démontré", "object": "Maîtrise exceptionnelle du langage Python" },
  { "subject": "Maîtrise exceptionnelle du langage Python", "predicate": "inclut", "object": "Résolution de problèmes complexes" },
  { "subject": "Maîtrise exceptionnelle du langage Python", "predicate": "inclut", "object": "Développement de projets ambitieux" }
]

            SYSTEM
          },
          {
            role: "user",
            content: prompt  # Le prompt de l'utilisateur
          }
        ],
        max_tokens: 500,
        temperature: 0.5
      }

      # Envoi de la requête à OpenAI
      response = HTTP.post(@url, headers: headers, json: data)

      # Vérification de la réponse de l'API
      if response.status != 200
        raise "OpenAI Error: #{response.body}"
      end

      # Extraction du texte brut de la réponse
      output = JSON.parse(response.body.to_s)["choices"][0]["message"]["content"].strip
      Rails.logger.info "Contenu brut extrait de l'API : #{output}"

      # Analyse et extraction des triples et du texte enrichi
      parse_output(output)

    rescue => e
      Rails.logger.error "Erreur lors de la requête à l'API OpenAI : #{e.message}"
      raise "Erreur avec l'API OpenAI : #{e.message}"
    end
  end

  private

  def parse_output(output)
    begin
      # Essayer de parser la réponse en JSON
      data = JSON.parse(output)
      {
        triples: data["triples"] || [],
        enriched_text: data["enriched_text"] || ""
      }
    rescue JSON::ParserError
      Rails.logger.warn "Impossible de parser JSON, renvoi du texte brut."
      {
        triples: [],
        enriched_text: output.strip
      }
    end
  end
end

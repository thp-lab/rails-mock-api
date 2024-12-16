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
Assurez-vous que la sortie est strictement au format JSON valide. Ne mélangez pas des chaînes de texte dans le même champ que les triples. Utilisez le format suivant pour vos sorties :

1. **Triples RDF** :
Générez un tableau de triples au format suivant. Si un triple contient un objet ou un sujet imbriqué, il doit être représenté comme un objet JSON à l’intérieur du triple.

2. **Interprétation textuelle** :
   Vous devez également produire une interprétation textuelle de la sémantique des triples précédemment créés, en les structurant pour en faire une recommandation claire, concise. Cela ne doit pas interférer avec les triples générés.


Lorsque c'est possible, structurez les triples de manière imbriquée pour représenter les relations complexes ou hiérarchiques décrites dans le texte.


**1.Structure du format Json attendu **
```json
{
triples:[
  { "subject": "Jean Dupont", "predicate": "a complété", "object": {
      "subject": "Formation Fullstack",
      "predicate": "session",
      "object": "Automne 2024 de THP"
    }
  },
  { "subject": "Jean Dupont"
   , "predicate": "a démontré", "object": {
      "subject": "Maîtrise des langages",
      "predicate": "inclut",
      "object": [
        { "subject": "Langage", "predicate": "inclut", "object": "Javascript" },
        { "subject": "Langage", "predicate": "inclut", "object": "Ruby" },
        { "subject": "Langage", "predicate": "inclut", "object": "React" }
      ]
    }
  },
  { "subject": "Jean Dupont", "predicate": "a travaillé sur", "object": {
      "subject": "Projet final",
      "predicate": "thème",
      "object": {
        "subject": "Thème",
        "predicate": "est basé sur",
        "object": [
          { "subject": "Format RDF", "predicate": "est", "object": "Technologie" },
          { "subject": "Protocole de Intuition,", "predicate": "utilise", "object": "Format RDF" }
        ]
      }
    }
  }

],
 enriched_text :
"Jean Dupont a réussi la formation Fullstack, session automne 2024 de THP, démontrant une maîtrise des langages Javascript, Ruby et React. Il a également appliqué ces compétences dans le projet final, en utilisant le format RDF et le protocole de Intuition."
}

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

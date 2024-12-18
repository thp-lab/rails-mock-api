require "http"
require "json"

class NlpService
  def initialize(api_key)
    raise "API key is missing" if api_key.nil? || api_key.empty?

    @api_key = api_key
  end

  def generate_triples_and_text(prompt)
    begin
      # Préparer la requête
      headers = {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{@api_key}"
      }

      instructions = <<~INSTRUCTIONS
        : Vous êtes un assistant IA spécialisé dans la génération de triples RDF à partir de descriptions textuelles. Votre tâche consiste à analyser un texte et à extraire les triples RDF au format suivant :
{ "subject": "<sujet>", "predicate": "<prédicat>", "object": "<objet>" }
Cependant, certains sujets, prédicats ou objets dans un triple peuvent eux-mêmes être des triples imbriqués. Vous devez les traiter de manière récursive, où un triple peut contenir un autre triple en tant qu'objet, sujet ou prédicat.
Assurez-vous que la sortie est strictement au format JSON valide. Ne mélangez pas des chaînes de texte simples dans le même champ que des triples JSON imbriqués. Utilisez le format suivant pour vos sorties :

Triples RDF :
Générez un tableau de triples RDF suivant les principes ci-dessous :
-Chaque triple doit être clair et refléter une relation sémantique précise entre un sujet, un prédicat, et un objet.
-Utilisez des triples imbriqués uniquement si cela enrichit la sémantique ou améliore la réutilisabilité.
-Chaque composant d’un triple (sujet, prédicat, objet) doit correspondre à un Atom unique, permettant la réutilisation dans différents contextes.
Interprétation textuelle :
-Fournissez une interprétation claire et concise des triples générés. Cette interprétation doit fournir une recommandation, enrichir le texte original en le rendant plus professionnel, avec un style précis, concis et détaillé.
-Analysez le texte en termes de structure logique et de connectivité, et apportez des explications supplémentaires qui ajoutent de la valeur au contenu original sans être trop emphatique.
Lors de l’interprétation, veillez à respecter les principes suivants :
-Lorsqu’un concept est exprimé de manière complexe ou hiérarchique, utilisez des structures imbriquées pour refléter cette complexité.
Structure JSON attendue :
{
  "triples": [
    {
      "subject": "Marie Curie",
      "predicate": "discovered",
      "object": {
        "subject": "radium",
        "predicate": "createdIn",
        "object": "1898"
      }
    },
    {
      "subject": "radium",
      "predicate": "contributedTo",
      "object": "cancer treatment"
    },
    {
      "subject": "Marie Curie",
      "predicate": "collaboratedWith",
      "object": "Pierre Curie"
    }
  ],
  "enriched_text": "Marie Curie discovered radium in 1898 with Pierre Curie. This discovery revolutionized cancer treatment."
}
Utilisez des triples imbriqués uniquement lorsque cela ajoute une richesse sémantique significative ou reflète des relations complexes.
      INSTRUCTIONS

      user_message = {
        role: "user",
        content: instructions + prompt
      }

      assistant_response = send_message_to_assistant(user_message, headers)
      Rails.logger.debug "Réponse de l'assistant : #{assistant_response}"


     assistant_response

    rescue => e
      Rails.logger.error "Erreur lors de la génération : #{e.message}"
      raise "Erreur avec l'API OpenAI : #{e.message}"
    end
  end

  private

  def send_message_to_assistant(user_message, headers)
    data = {
      model: "gpt-3.5-turbo",
      messages: [ user_message ]
    }

    response = HTTP.post("https://api.openai.com/v1/chat/completions", headers: headers, json: data)

    if response.status != 200
      raise "Erreur lors de la requête : #{response.body}"
    end

    JSON.parse(response.body.to_s)["choices"][0]["message"]["content"].strip
  end

  def validate_triples(triples)
    return [] unless triples.is_a?(Array)

    triples.select do |triple|
      triple.is_a?(Hash) && triple.key?("subject") && triple.key?("predicate") && triple.key?("object")
    end
  end
end

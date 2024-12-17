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
{ "subject": "<sujet>", "predicate": "<prédicat>", "object": "<objet>" }
Cependant, certains sujets, prédicats ou objets dans un triple peuvent eux-mêmes être des triples imbriqués. Vous devez les traiter de manière récursive, où un triple peut contenir un autre triple en tant qu'objet, sujet ou prédicat.
Assurez-vous que la sortie est strictement au format JSON valide. Ne mélangez pas des chaînes de texte simples dans le même champ que des triples JSON imbriqués. Utilisez le format suivant pour vos sorties :

Triples RDF :
Générez un tableau de triples RDF suivant les principes ci-dessous :

Chaque triple doit être clair et refléter une relation sémantique précise entre un sujet, un prédicat, et un objet.
Utilisez des triples imbriqués uniquement si cela enrichit la sémantique ou améliore la réutilisabilité.
Chaque composant d’un triple (sujet, prédicat, objet) doit correspondre à un Atom unique, permettant la réutilisation dans différents contextes.
Interprétation textuelle :
Fournissez une interprétation claire et concise des triples générés. Cette interprétation doit enrichir le texte original en le rendant plus professionnel, avec un style précis et détaillé.

Mettez en lumière la signification des triples extraits, expliquant leur contexte et leur relation dans le cadre du texte analysé.
Analysez le texte en termes de structure logique et de connectivité, et apportez des suggestions ou des explications supplémentaires qui ajoutent de la valeur au contenu original sans être trop emphatique.
Lors de l’interprétation, veillez à respecter les principes suivants :

Lorsqu’un concept est exprimé de manière complexe ou hiérarchique, utilisez des structures imbriquées pour refléter cette complexité.
Privilégiez l’utilisation de triples réutilisables pour éviter la duplication excessive des Atoms.
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
Chaque sujet, prédicat, ou objet doit être représenté par un Atom distinct et identifiable.
Minimisez la fragmentation des triples pour maximiser leur réutilisabilité dans d'autres contextes RDF.
Utilisez des triples imbriqués uniquement lorsque cela ajoute une richesse sémantique significative ou reflète des relations complexes.
Exemple :
{
  "subject": "Final Project",
  "predicate": "demonstrates",
  "object": {
    "subject": "Jean Dupont",
    "predicate": "mastered",
    "object": [
      { "subject": "Javascript", "predicate": "usedIn", "object": "Final Project" },
      { "subject": "Ruby", "predicate": "usedIn", "object": "Final Project" },
      { "subject": "React", "predicate": "usedIn", "object": "Final Project" }
    ]
  }
}

Production stricte au format JSON :
Assurez-vous que la sortie est conforme au format JSON et qu'elle respecte les conventions décrites ci-dessus.

Exemple d’entrée :
Texte Source :

"Jean Dupont a réussi la formation Fullstack, session automne 2024 de THP, démontrant une maîtrise des langages Javascript, Ruby et React. Il a également appliqué ces compétences dans le projet final, en utilisant le format RDF et le protocole de Intuition."

Exemple de sortie attendue :
{
  "triples": [
    {
      "subject": "Jean Dupont",
      "predicate": "completed",
      "object": "Fullstack Training THP Autumn 2024"
    },
    {
      "subject": "Jean Dupont",
      "predicate": "mastered",
      "object": [
        { "subject": "Javascript", "predicate": "usedIn", "object": "Final Project" },
        { "subject": "Ruby", "predicate": "usedIn", "object": "Final Project" },
        { "subject": "React", "predicate": "usedIn", "object": "Final Project" }
      ]
    },
    {
      "subject": "Final Project",
      "predicate": "utilized",
      "object": "RDF Format and Intuition Protocol"
    }
  ],
  "enriched_text": "Jean Dupont successfully completed the Fullstack training organized by THP during the Autumn 2024 session. This intensive program enabled him to master essential programming languages such as Javascript, Ruby, and React, which he then applied successfully in his final project. The project incorporated the use of RDF format and Intuition protocol, demonstrating his ability to work with cutting-edge technologies."
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

class Creator < ApplicationRecord
  self.primary_key = "label"

  has_many :atoms, dependent: :destroy
  has_many :triples, dependent: :destroy

  validates :label, presence: true
  validates :image, presence: true
end

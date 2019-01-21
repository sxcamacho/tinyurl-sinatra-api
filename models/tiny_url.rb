class TinyUrl
  include Mongoid::Document

  field :url, type: String
  field :tiny_url, type: String
  field :tiny_id, type: String

  validates :url, presence: true

  index({ url: 1 }, { unique: true, name: "url_index" })
  index({ tiny_url: 1 }, { unique: true, name: "tiny_url_index" })
  index({ tiny_id: 1 }, { unique: true, name: "tiny_id_index" })

  scope :find_by_url, -> (param_url) { where(url: param_url) }
  scope :find_by_tiny_id, -> (id) { where(tiny_id: id) }
end
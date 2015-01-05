class TransportType
  include Mongoid::Document
  field :name
  has_many :vertexes
end
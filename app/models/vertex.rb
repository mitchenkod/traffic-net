class Vertex
  include Mongoid::Document

  field :x, type: Float
  field :y, type: Float

  has_many :outcoming_edges, class_name: 'Edge', inverse_of: :outcoming_vertex
  has_many :incoming_edges, class_name: 'Edge', inverse_of: :incoming_vertex


end
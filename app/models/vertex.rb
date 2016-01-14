class Vertex
  include Mongoid::Document

  field :x,    type: Float
  field :y,    type: Float
  field :val
  field :simple_id, type: Integer
  field :marked, default: false

  has_many :outcoming_edges, class_name: 'Edge', inverse_of: :outcoming_vertex
  has_many :incoming_edges,  class_name: 'Edge', inverse_of: :incoming_vertex

  belongs_to :source
  has_many   :routes_outlet, class_name: 'Route', inverse_of: :outlet

  def weight(attr)
    try(attr) || 0
  end

  def children
    outcoming_edges.map {|edge| edge.outcoming_vertex}
  end

end
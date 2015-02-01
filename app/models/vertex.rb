class Vertex
  include Mongoid::Document

  field :x,    type: Float
  field :y,    type: Float
  field :val

  has_many :outcoming_edges, class_name: 'Edge', inverse_of: :outcoming_vertex
  has_many :incoming_edges,  class_name: 'Edge', inverse_of: :incoming_vertex

  belongs_to :source
  has_many   :routes_outlet, class_name: 'Route', inverse_of: :outlet

  def weight(attr)
    try(attr)
  end

  def children
    outcoming_edges.map {|edge| edge.outcoming_vertex}
  end

end
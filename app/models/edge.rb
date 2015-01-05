class Edge
  include Mongoid::Document

  belongs_to :transport_type

  belongs_to :outcoming_vertex, class_name: 'Vertex', inverse_of: :outcoming_edges
  belongs_to :incoming_vertex, class_name: 'Vertex', inverse_of: :incoming_edges

end
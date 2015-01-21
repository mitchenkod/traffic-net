class Edge
  include Mongoid::Document

  COEF_CONGESTED = 1.5
  COEF_JAM = 2

  belongs_to :transport_type

  belongs_to :outcoming_vertex, class_name: 'Vertex', inverse_of: :outcoming_edges
  belongs_to :incoming_vertex, class_name: 'Vertex', inverse_of: :incoming_edges

  field :val
  field :p_max, type: Integer, default: 5
  field :p_mid, type: Integer, default: 3
  field :business, type: Integer, default: 0
  field :t_0, type: Integer, default: 10

  def weight(attr)
    try(attr) || 0
  end

  def t_res
    case
      when business < p_mid
        return t_0
      when business >= p_mid && business < p_max
        return t_0 * COEF_CONGESTED
      when business >=p_max
        return t_0 * COEF_JAM
    end
  end

end
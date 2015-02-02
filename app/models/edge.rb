class Edge
  include Mongoid::Document

  COEF_CONGESTED = 1.5
  COEF_JAM = 2

  belongs_to :transport_type

  belongs_to :outcoming_vertex, class_name: 'Vertex', inverse_of: :outcoming_edges
  belongs_to :incoming_vertex, class_name: 'Vertex', inverse_of: :incoming_edges

  has_and_belongs_to_many :routes

  field :val
  field :p_max, type: Integer, default: 5
  field :p_mid, type: Integer, default: 3
  field :business, type: Integer, default: 0
  field :t_0, type: Integer, default: 10

  field :reverse_on, default: false
  field :has_reverse, default: false


  def p_mid
    reverse_on ? 200 : 300
  end

  def weight(attr)
    try(attr) || 0
  end

  def flow_state
    case
      when business < p_mid
        return 'free'
      when business >= p_mid && business < p_max
        return 'congested'
      when business >=p_max
        return 'jam'
    end
  end

  def t_res
    (t_0*(1 + (business.to_f/p_mid)) ** 4).to_i
  end


end
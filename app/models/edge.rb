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
  field :enable, default: true

  after_save :check_reverse


  def p_mid
    reverse_on ? 300 : 200
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

  private
  def check_reverse
    if business_changed?
      if business > 400 && business-business_was >=  100 && has_reverse && !reverse_on
        open_reverse
      end
    end
  end

  def open_reverse
    update_attribute :reverse_on, true
  end

end
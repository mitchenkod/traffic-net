class Route
  include Mongoid::Document

  belongs_to              :source
  belongs_to              :outlet, class_name: 'Vertex', inverse_of: :routes_outlet
  has_and_belongs_to_many :edges


  def add_flow(rate)
    edges.each do |edge|
      edge.update_attribute :business, (edge.business||0) + rate
    end
  end

  def t
    edges.inject(0) {|sum, edge| edge.t_res + sum}
  end

end
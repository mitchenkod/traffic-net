class Source

  INFINITY = 1 << 32

  include Mongoid::Document

  belongs_to :vertex

  has_many :routes

  field :incoming_flow

  field :current_flow, default: 0

  def min_route
    res = routes.first
    min = res.t
    routes.each do |route|
      possible_min = route.t
      if possible_min < min
        res = route
        min = possible_min
      end
    end
    res
  end

  def increase_flow(rate)
    if (current_flow||0) - rate >= 0
      min_route.add_flow(rate)
      update_attribute :current_flow, current_flow-rate
      return true
    else
      min_route.add_flow(current_flow||0)
      update_attribute :current_flow, 0
      return false
    end
  end

end
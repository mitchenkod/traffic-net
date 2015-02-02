class Hypernet

  INFINITY = 1 << 32

  def self.dijkstra(v0, weight_function)
    vertices = Vertex.all.to_a
    ver_num = vertices.length
    vert_hash = Hash[vertices.map.with_index.to_a]
    vis = Array.new(ver_num) {false}
    weights = Array.new(ver_num) {INFINITY}
    v0_num = vert_hash[v0]
    weights[v0_num] = 0
    for i in 0..ver_num-1
      min_weight = INFINITY
      min_weight_id = -1
      for i in 0..ver_num-1
        if weights[i] < min_weight && !vis[i]
          min_weight = weights[i]
          min_weight_id = i
        end
      end
      vertices[min_weight_id].outcoming_edges.each do |e|
        v = e.incoming_vertex
        if weights[min_weight_id] + e.weight(weight_function) + v.weight(weight_function) < weights[vert_hash[v]]
          weights[vert_hash[v]] = weights[min_weight_id] + e.weight(weight_function) + v.weight(weight_function)
        end
      end
      vis[min_weight_id] = true
    end
    return weights.each_with_index.map {|w, i| [w, vertices[i].id.to_s]}
  end


  def self.clean_up_routes
    Edge.each {|edge| edge.update_attribute :business, 0}
    Source.each {|source| source.update_attribute :current_flow, source.incoming_flow}
  end

  def self.costs
    flow_rate = Source.all.inject(0) {|sum, source| sum + source.incoming_flow}
    Edge.all.inject(0) {|sum, edge| sum + edge.t_res*edge.business }/flow_rate
  end


  def self.iterate_flows(delta)
    Source.each {|source| source.increase_flow(delta)}
  end


  def self.compute_final_state
    (1..40).each do |n|
      self.iterate_flows(10)
    end
    self.iterate_flows(300)
  end

end
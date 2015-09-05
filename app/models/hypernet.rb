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
    Edge.where(reverse_on: true).each {|edge| edge.update_attribute :reverse_on, false}
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


  def self.generate_net
    1.upto(10) do |i|
      1.upto(10) do |j|
       Vertex.create x: i * 50,# + (Random.rand(5) - Random.rand(40)),
                     y: j * 50, #+ (Random.rand(5) - Random.rand(40))
                     simple_id: i*10 + j
      end
    end

    Vertex.each do |v|
      -1.upto(1) do |i|
        -1.upto(1) do |j|
          if i != 0 && j != 0
            up = Vertex.find_by simple_id: v.simple_id - 1 if v.simple_id % 10 != 1
            down = Vertex.find_by simple_id: v.simple_id + 1 if v.simple_id % 10 != 0
            left = Vertex.find_by simple_id: v.simple_id + 10 if v.simple_id < 100
            right = Vertex.find_by simple_id: v.simple_id - 10 if v.simple_id > 20
            Edge.create! outcoming_vertex: v, incoming_vertex: up if up
            Edge.create! outcoming_vertex: v, incoming_vertex: down if down
            Edge.create! outcoming_vertex: v, incoming_vertex: left if left
            Edge.create! outcoming_vertex: v, incoming_vertex: right if right
            Edge.create! outcoming_vertex: up, incoming_vertex: v if up
            Edge.create! outcoming_vertex: down, incoming_vertex: v if down
            Edge.create! outcoming_vertex: left, incoming_vertex: v if left
            Edge.create! outcoming_vertex: right, incoming_vertex: v if right
          end
        end
      end
    end
  end

end
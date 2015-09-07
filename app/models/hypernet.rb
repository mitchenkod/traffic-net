class Hypernet

  require 'matrix'

  INFINITY = 1 << 32

  k = 2
  n = 3
  m = 3


  def self.matmult(a, b)
    res = []
    a.each do |line|
      sum = 0
      line.each_with_index do |elem, i|
        sum += elem * b[i]
      end
      res << sum
    end
    res
  end

  def self.check_solution(n, m, k)
    res = []# Array.new(m*n*k, 1)
    0.upto(n*m*k) do
      res << Math.random(200)
    end
    matmult( build_matrix(n,m,k), create_solution(n,m,k, res))
  end

  def self.create_solution(n, m, k, res)
    c = Array.new(m + n -1 , 20)
    #
    0.upto(m-2) do |j|
      other = 0
      1.upto(k-1) do |l|
        other += res[j*k + l]
      end
      1.upto(n-1) do |i|
        0.upto(k-1) do |l|
          other += res[j*k + i*k*m]
        end
      end
      res[j*k] = c[n + j] - other
    end
    0.upto(n-1) do |i|
      sum = 0
      0.upto(m-2) do |j|
        0.upto(k-1) do |l|
          sum += res[i*k*m + j*k + l]
        end
      end
      0.upto(k-2) do |l|
        sum += res[i*k*m + (m-1)*k + l]
      end
      res[(i+1)*k*m -1] = c[i] - sum
    end
    res
  end

  def self.dijkstra(v0,v1 = nil,  weight_function)
    vertices = Vertex.all.to_a
    ver_num = vertices.length
    vert_hash = Hash[vertices.map.with_index.to_a]
    vis = Array.new(ver_num) {false}
    weights = Array.new(ver_num) {INFINITY}
    v0_num = vert_hash[v0]
    weights[v0_num] = 0
    last_vert = Array.new(ver_num)
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
        if e.enable
          v = e.incoming_vertex
          if weights[min_weight_id] + e.weight(weight_function) + v.weight(weight_function) < weights[vert_hash[v]]
            weights[vert_hash[v]] = weights[min_weight_id] + e.weight(weight_function) + v.weight(weight_function)
            last_vert[vert_hash[v]] = vertices[min_weight_id].id.to_s
          end
        end
        vertices[min_weight_id]
      end
      vis[min_weight_id] = true
    end
    if v1
      Vertex.each {|vert| vert.update marked: false}
      vtemp = v1
      vtemp.update marked: true
      path = [v1]
      res = while vtemp != v0 do
        return nil if last_vert[vert_hash[vtemp]].nil?
        vtemp = Vertex.find last_vert[vert_hash[vtemp]]
        vtemp.update marked: true
        path << vtemp.id.to_s
      end
      if res == -1
        return nil
      end
    end
    res_edges = []
    path.each_with_index do |v1, i|
      if path[i+1].present?
        res_edges << Edge.where(incoming_vertex: v1, outcoming_vertex: path[i+1]).first
      end
    end
    res_edges
  end

  def self.yen(v0, v1, k)
    Edge.each {|edge| edge.update enable: true}
    Route.delete_all
    paths = dijkstra(v0, v1, 'val') || path
    paths_new = []
    source = Source.create vertex: v1
    Route.create source: source, outlet: v1, edges: paths
    1.upto(k) do
      edge_temp = nil
      min = INFINITY
      path_new = nil
      paths.each do |edge|
        edge.update enable: false
        temp = dijkstra(v0, v1, 'val')
        if temp.present?
          paths_new = temp
          edge_temp = edge
        end
        edge.update enable: true
      end
      edge_temp.update enable: false
      if paths_new.present?
        paths = paths_new
        Route.create source: source, outlet: v1, edges: paths
      end
    end
  end

  def self.build_matrix(n, m, k)



    matr = Array.new m+n-1
    0.upto(n-1) do |i|
      matr[i] = Array.new(m*n*k, 0)
      0.upto(m-1) do |j|
        0.upto(k-1) do |l|
          matr[i][i*m*k + j*k + l] = 1
        end
      end
    end
    0.upto(m-2) do |j|
      matr[n+j] = Array.new(m*n*k, 0)
      0.upto(n-1) do |i|
        0.upto(k-1) do |l|
          matr[n+j][k*j + k*m*i + l] = 1
        end
      end
    end
    matr
  end

  def self.print_matrix(n,m,k)
    build_matrix(n,m,k).each do |line|
      out_line = ""
      line.each do |elem|
       out_line += "#{elem} "
      end
      puts out_line
    end
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


  def self.generate_net(n, m)
    Vertex.delete_all
    Edge.delete_all
    1.upto(n) do |i|
      1.upto(m) do |j|
       Vertex.create x: i *100,# + (Random.rand(5) - Random.rand(40)),
                     y: j * 100, #+ (Random.rand(5) - Random.rand(40))
                     simple_id: i*10 + j
      end
    end

    Vertex.each do |v|
      up = Vertex.where(simple_id: v.simple_id - 1).first
      down = Vertex.where(simple_id: v.simple_id + 1).first
      left = Vertex.where(simple_id: v.simple_id + 10).first
      right = Vertex.where(simple_id: v.simple_id - 10).first
      if up
        Edge.create! outcoming_vertex: v, incoming_vertex: up if Edge.where(outcoming_vertex: v.id, incoming_vertex: up.id).first.nil?
        Edge.create! outcoming_vertex: up, incoming_vertex: v if Edge.where(outcoming_vertex: up.id, incoming_vertex: v.id).first.nil?
      end
      if down
        Edge.create! outcoming_vertex: v, incoming_vertex: down if Edge.where(outcoming_vertex: v.id, incoming_vertex: down.id).first.nil?
        Edge.create! outcoming_vertex: down, incoming_vertex: v if Edge.where(outcoming_vertex: down.id, incoming_vertex: v.id).first.nil?
      end
      if left
        Edge.create! outcoming_vertex: v, incoming_vertex: left if Edge.where(outcoming_vertex: v.id, incoming_vertex: left.id).first.nil?
        Edge.create! outcoming_vertex: left, incoming_vertex: v if Edge.where(outcomirng_vertex: left.id, incoming_vertex: v.id).first.nil?
      end
      if right
        Edge.create! outcoming_vertex: v, incoming_vertex: right if Edge.where(outcoming_vertex: v.id, incoming_vertex: right.id).first.nil?
        Edge.create! outcoming_vertex: right, incoming_vertex: v if Edge.where(outcoming_vertex: right.id, incoming_vertex: v.id).first.nil?
      end
    end
  end

end
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
    last_vert = Hash[vertices.map.with_index.to_a]
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
          last_vert[vert_hash[v]] = min_weight_id
        end
      end
      vis[min_weight_id] = true
    end
    edges = []
    weights.each_with_index.map {|w, i| [w, vertices[i].id.to_s]}.each_slice(2) do |v1, v2|
      if v1.present? && v2.present?
        edges << Edge.where(incoming_vertex: v1[1], outcoming_vertex: v2[1]).first
      end
    end
    if v1
      vtemp = v1
      path = []
      while vtemp != v0 do
        vtemp = Vertex.find last_vert[vtemp.id.to_s]
        path << vtemp.id.to_s
      end
    end
    path
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
      -1.upto(1) do |i|
        -1.upto(1) do |j|
          if i != 0 && j != 0
            up = Vertex.where(simple_id: v.simple_id - 1).first
            down = Vertex.where(simple_id: v.simple_id + 1).first
            left = Vertex.where(simple_id: v.simple_id + 10).first
            right = Vertex.where(simple_id: v.simple_id - 10).first
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
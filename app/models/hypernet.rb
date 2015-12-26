class Hypernet

  require 'matrix'

  INFINITY = 1 << 32

  k = 2
  n = 3
  m = 3


  def self.sources
    Source.all.map(:vertex)
  end

  def self.outlets
    res = []
    Route.each do |route|
      res << route.outlet unless res.include?(route.outlet)
    end
    res
  end

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
      res << Math.send('rand', 5)
    end
    matmult( build_matrix(n,m,k), create_solution(n,m,k, res))
  end

  def self.rho
    [[10, 0, 10, 0, 10],
     [10, 0, 10, 0, 10],
     [10, 0, 10, 0, 10],
     [10, 0, 10, 0, 10],
     [10, 0, 10, 0, 10]]
  end

  def self.non_zero_routes
    res = []
    rho.each_with_index do |row, i|
      row.each_with_index do |elem, j|
        res << [sources[i], outlets[j], rho[i][j]] if elem > 0
      end
    end
    res
  end



  def self.create_solution(n, m, k, res)
    c = Array.new(m + n -1 , 100)
    #
    0.upto(m-2) do |j|
      other = 0
      1.upto(k-1) do |l|
        other += res[j*k + l]
      end
      1.upto(n-1) do |i|
        0.upto(k-1) do |l|
          other += res[j*k + i*k*m + l]
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

  def self.generate_routes(sources, outlets)
    Route.delete_all
    i = 0
    sources.each do |source_id|
      outlets.each do |outlet_id|
        source = Vertex.find_by simple_id: source_id
        outlet = Vertex.find_by simple_id: outlet_id
        yen(source, outlet, 5)
        puts i
        i += 1
      end
    end

  end

  def connected(v0, v1)



  end

  def self.yen(v0, v1, k)
    Edge.each {|edge| edge.update enable: true}
    paths = dijkstra(v0, v1, 'val') || path
    paths_new = []
    source = Source.find_or_create_by vertex: v0.id
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
      edge_temp.update enable: false if edge_temp
      if paths_new.present?
        paths = paths_new
        Route.create source: source, outlet: v1, edges: paths
      end
    end
  end


  def self.solve_genetic(p_num)
    ::Algorithms::GeneticService.new.solve(p_num)
  end

  def self.apply_solution
    time_start = Time.now
    min_costs = INFINITY
    final_sol = []
    1.upto(5) do |i|
      1.upto(5) do |j|
        1.upto(5) do |k|
          1.upto(5) do |l|
            1.upto(5) do |m|
              clean_up_routes
              sol = create_solution(2, 2, 2, [1, i, j, 1, k, l, m, 1])
              valid = true
              sol.each_with_index do |flow, i|
                if flow > 0
                  Route.all[i].add_flow(flow)
                else
                  valid = false
                end
              end
              puts "#{i} #{j} #{k} #{l} #{m} #{costs}"
              if valid

                temp = costs
                if min_costs > temp
                  min_costs = temp
                  final_sol = sol
                end
              end
            end
          end
        end
      end
    end
    [min_costs, final_sol]
    time_finish = Time.now
    # population
    time_finish - time_start
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
    matr.each do |row|
      str_row = ''
      row.each {|elem| str_row += "#{elem} "}
      puts str_row
    end
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

  def self.load_up_sources
    Source.each {|source| source.update_attribute :incoming_flow, 100}
  end

  def self.clean_up_routes
    Edge.each {|edge| edge.update_attribute :business, 0}
    Source.each {|source| source.update_attribute :current_flow, source.incoming_flow}
    Edge.where(reverse_on: true).each {|edge| edge.update_attribute :reverse_on, false}
  end
  #1156618052817
  def self.costs
    # flow_rate = Source.all.inject(0) {|sum, source| sum + source.incoming_flow}
    Edge.all.inject(0) {|sum, edge| sum + edge.t_res }
  end


  def self.iterate_flows(delta)
    Source.each {|source| source.increase_flow(delta)}
  end


  def self.compute_final_state
    clean_up_routes
    time_start = Time.now
    (1..100).each do |n|
      self.iterate_flows(1)
      puts n
    end
    time_finish = Time.now
    # population
    time_finish - time_start
    # self.iterate_flows(300)
  end


  def self.create_sources(sources)
    sources.each do |source|
      vertex = Vertex.where(simple_id: source).first
      Source.create! vertex: vertex, incoming_flow: 50
    end
  end


  def self.create_outlets(sources)
    sources.each do |source|
      vertex = Vertex.where(simple_id: source).first
      Source.create! vertex: vertex, incoming_flow: 50
    end
  end

  def self.generate_net(n, m)
    Vertex.delete_all
    Edge.delete_all
    1.upto(n) do |i|
      1.upto(m) do |j|
       Vertex.create x: i * 50 + (Random.rand(20) - Random.rand(40)),
                     y: j * 50 + (Random.rand(20) - Random.rand(40)),
                     simple_id: i*100 + j
      end
    end

    Vertex.each do |v|
      up = Vertex.where(simple_id: v.simple_id - 1).first
      down = Vertex.where(simple_id: v.simple_id + 1).first
      left = Vertex.where(simple_id: v.simple_id + 100).first
      right = Vertex.where(simple_id: v.simple_id - 100).first
      rand = Math.send('rand', 100)
      if up && rand < 50
        Edge.create! outcoming_vertex: v, incoming_vertex: up if Edge.where(outcoming_vertex: v.id, incoming_vertex: up.id).first.nil?
        Edge.create! outcoming_vertex: up, incoming_vertex: v if Edge.where(outcoming_vertex: up.id, incoming_vertex: v.id).first.nil?
      end
      if down && rand < 50
        Edge.create! outcoming_vertex: v, incoming_vertex: down if Edge.where(outcoming_vertex: v.id, incoming_vertex: down.id).first.nil?
        Edge.create! outcoming_vertex: down, incoming_vertex: v if Edge.where(outcoming_vertex: down.id, incoming_vertex: v.id).first.nil?
      end
      if left && rand < 50
        Edge.create! outcoming_vertex: v, incoming_vertex: left if Edge.where(outcoming_vertex: v.id, incoming_vertex: left.id).first.nil?
        Edge.create! outcoming_vertex: left, incoming_vertex: v if Edge.where(outcomirng_vertex: left.id, incoming_vertex: v.id).first.nil?
      end
      if right && rand < 50
        Edge.create! outcoming_vertex: v, incoming_vertex: right if Edge.where(outcoming_vertex: v.id, incoming_vertex: right.id).first.nil?
        Edge.create! outcoming_vertex: right, incoming_vertex: v if Edge.where(outcoming_vertex: right.id, incoming_vertex: v.id).first.nil?
      end
    end
    Vertex.each do |v|
      if Edge.where(outcoming_vertex: v.id).count == 0 && Edge.where(incoming_vertex: v.id).count == 0
        v.destroy!
      end
    end
  end

end
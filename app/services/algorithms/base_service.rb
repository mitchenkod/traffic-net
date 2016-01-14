module Algorithms
  class BaseService

    INFINITY = 1 << 32

    def count_fitness(k, res)
      Hypernet.clean_up_routes
      routes_t = []
      # puts res
      Hypernet.non_zero_routes.each_with_index do |route, i|
        routes_t = []
        arr = res.slice (i*(k-1))..(i+1)*(k-1) - 1
        arr.sort!
        last_elem = 0
        new_elem = 0
        arr.each do |elem|
          new_elem = elem.to_i
          routes_t << new_elem - last_elem
          last_elem = new_elem
        end
        routes_t << route[2] - last_elem
        Route.where(source: route[0], outlet: route[1]).each_with_index do |route, i|
          # puts route.id
          # puts routes_t[i]
          route.add_flow(routes_t[i])
        end

      end
      Hypernet.costs
    end


  end
end
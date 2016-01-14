module Algorithms
  class GeneticService < BaseService

    def solve(p_num)
      time_start = Time.now
      n = 10 #source number
      m = 10 #outlets number
      k = 5 #path number
      population = []
      fitness = []
      res = []
      iter_count = 0
      1.upto(p_num) do
        sol = create_individual(k)
        population << sol
        fitness << count_fitness(k, sol)
      end
      before_min = fitness.inject(INFINITY) {|f, min| [f,min].min }
      puts before_min
      strike = 0
      while strike < 4
        iter_count += 1
        new_fitness = []
        population = new_population n, m, k, population, fitness, p_num
        # puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        population.each do |ind|
          new_fitness << count_fitness( k, ind)
          # puts ind.inject('') {|elem, sum| elem + ' ' + sum}
        end
        # puts '!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
        min = new_fitness.inject(INFINITY) {|f, min| [f,min].min }
        res << min
        # puts min
        fitness = new_fitness
        if (before_min - min).abs.to_f / before_min < 0.001
          strike += 1
        else
          strike = 0
          before_min = min
        end
      end
      time_finish = Time.now
      # population
      [res.min, time_finish - time_start, iter_count]
    end

    def create_individual(k)
      res = []
      Hypernet.non_zero_routes.each do |route|
        0.upto(k-2) do |i|
          gen = Random.rand route[2]+1
          res << "#{gen}" if gen >= 10
          res << "0#{gen}" if gen < 10
        end
      end
      res
    end

    def owl_buying(n, m, k, parent_one, parent_two)
      len = parent_one.length
      rand = Random.rand Hypernet.incoming_flow
      res = Array.new len
      cross = Random.new.rand(len) - 1
      cross = 1 if cross <= 0
      res[0,cross] = (rand < 5 ? parent_one[0,cross] : parent_two[0,cross])
      res[cross, len-1] = (rand > 5 ? parent_one[cross, len-1] : parent_two[cross, len-1])
      if Random.rand(100) < 50
        1.upto(Random.rand(len/2).to_i) do
          i = (Random.rand len).to_i
          res[i] = (Random.rand Hypernet.incoming_flow).to_i.to_s
          res[i] = "0#{res[i]}" if res[i].length == 1
        end
      end
      res
    end

    def new_population(n, m, k, population, fitness, p_num)
      res = []
      1.upto(p_num) do
        i = (Random.rand population.length).to_i
        j = (Random.rand population.length).to_i
        q = (Random.rand population.length).to_i
        l = (Random.rand population.length).to_i
        child_i = fitness[i] < fitness[j] ? i : j
        child_j = fitness[q] < fitness[l] ? q : l
        res << (owl_buying n, m, k,  population[child_i], population[child_j])
      end
      res
    end

    def results(p_num, len)
      time = 0
      res = 0
      iter = 0
      1.upto len do |i|
        puts i
        temp_res = solve(p_num)
        res += temp_res[0]
        time += temp_res[1]
        iter += temp_res[2]
      end
      [res.to_f/len, time/len, iter.to_f/len]
    end

  end


end
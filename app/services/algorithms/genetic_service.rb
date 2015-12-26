module Algorithms
  class GeneticService

    def solve(p_num)
      time_start = Time.now
      n = 10 #source number
      m = 10 #outlets number
      k = 5 #path number
      population = []
      fitness = []
      1.upto(p_num) do
        sol = create_individual(n,m,k)
        population << sol
        fitness << count_fitness(n, m, k, sol)
      end
      before_min = fitness.inject(INFINITY) {|f, min| [f,min].min }
      puts before_min
      strike = 0
      while strike < 5
        new_fitness = []
        population = new_population n, m, k, population, fitness, p_num
        population.each do |ind|
          new_fitness << count_fitness(n, m, k, ind)
        end
        min = new_fitness.inject(INFINITY) {|f, min| [f,min].min }
        puts min
        fitness = new_fitness
        if (before_min - min).abs.to_f / before_min < 0.0001
          strike += 1
        else
          strike = 0
          before_min = min
        end
      end
      time_finish = Time.now
      # population
      time_finish - time_start
    end

    def create_individual(n, m, k)
      res = []
      Hypernet.non_zero_routes.each do |route|
        0.upto(k-1) do |i|
          gen = Math.send('rand', route[2]+1)
          res << "#{gen}" if gen >= 10
          res << "0#{gen}" if gen < 10
        end
      end
      res
    end

    def self.owl_buying(n, m, k, parent_one, parent_two)

      len = parent_one.length
      rand = Random.new.rand 10
      res = Array.new len
      cross = Random.new.rand(len - 3) + 1
      res[0,cross] = (rand < 5 ? parent_one[0,cross] : parent_two[0,cross])
      res[cross, len-1] = (rand > 5 ? parent_one[cross, len-1] : parent_two[cross, len-1])
      before_mutation = create_solution n, m, k, res
      if Random.new.rand(100) < 50
        1.upto(Random.new.rand(len/2).to_i) do
          i = (Random.new.rand m*n*k).to_i
          res[i] = (Random.new.rand 50).to_i
        end
      end
      prod = 1
      res = create_solution(n, m, k, res)
      res.each {|x| prod = -1 if x<=0}
      prod
      res = before_mutation if prod < 0
      res
    end

    def self.new_population(n, m, k, population, fitness, p_num)
      res = []
      1.upto(p_num) do
        i = (Random.new.rand population.length).to_i
        j = (Random.new.rand population.length).to_i
        q = (Random.new.rand population.length).to_i
        l = (Random.new.rand population.length).to_i
        child_i = fitness[i] < fitness[j] ? i : j
        child_j = fitness[q] < fitness[l] ? q : l
        res << (owl_buying n, m, k,  population[child_i], population[child_j])
      end
      res
    end

    def self.count_fitness(n, m, k, res)
      clean_up_routes
      res.each_with_index do |flow, i|
        Route.all[i].add_flow(flow)
      end
      costs
    end

  end

  def create_solution

  end
end
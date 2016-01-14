module Algorithms
  class FullSearchService < BaseService

    def solve
      time_start = Time.now

      min = INFINITY

      '00'.upto('10') do |i|
        '00'.upto('10') do |j|
          '00'.upto('10') do |k|
            '00'.upto('10') do |l|
              new_min = count_fitness(2, [i,j,k,l])
              puts "#{i} #{j} #{k} #{l} #{new_min}"
              min = new_min if new_min < min
            end
          end
        end
      end
      time_finish = Time.now
      # population
      [time_finish - time_start, min]
    end

  end
end
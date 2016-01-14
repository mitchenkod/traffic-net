module Api
  class RoutesController < ApplicationController

    respond_to :json

    def index
      @routes = Route.all.map do |route|
        route
        {
            id: route.id.to_s,
            edges_ids: route.edge_ids.map {|edge| edge.to_s},
            vertex_id: route.source.vertex.id.to_s
        }
      end
      respond_with @routes
    end
  end
end
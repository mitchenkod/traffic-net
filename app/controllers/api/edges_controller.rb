module Api
  class EdgesController < ApplicationController

    respond_to :json

    def create
      @edge = Edge.new edge_params
      if @edge.save
        head :ok
      else
        respond_with @edge.errors.messages
      end
    end

    def index
      res = Edge.all.map do |edge|
        {id: edge.id,
        x_1: edge.incoming_vertex.x,
        y_1: edge.incoming_vertex.y,
        x_2: edge.outcoming_vertex.x,
        y_2: edge.outcoming_vertex.y,
        }
      end
      respond_with res
    end

    private

    def edge_params
      params.require(:edge).permit(:outcoming_vertex_id, :incoming_vertex_id, :transport_type_id)
    end
  end
end
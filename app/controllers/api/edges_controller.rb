module Api
  class EdgesController < ApplicationController

    respond_to :json

    def create
      @edge = Edge.new edge_params
      if @edge.save
        head :ok
      else
        respond_with @edge.errors.messege
      end
    end

    def index
      @edges = Edge.all
      respond_with @edges
    end

    private

    def edge_params
      params.require(:edge).permit(:outcoming_vertex_id, :incoming_vertex_id, :transport_type_id)
    end
  end
end
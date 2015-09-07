module Api
  class VerticesController < ApplicationController

    respond_to :json

    def index
      @vertices = Vertex.all.map do |vert|
        {
            id: vert.id.to_s,
            x: vert.x,
            y: vert.y,
            simple_id: vert.simple_id,
            marked: vert.marked

        }
      end
      respond_with @vertices
    end

    def create
      @vertex = Vertex.new vertex_attributes
      if @vertex.save
        head :ok
      else
        respond_with @vertex.errors.message
      end
    end


    private
    def vertex_attributes
      params.require(:vertex).permit(:x, :y)
    end

  end
end
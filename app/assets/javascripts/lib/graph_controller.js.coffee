class @GraphController

  canvas: null
  vertices: []
  edges: []

  constructor: ->
    $('#net_here').click @new_vertex
    c=document.getElementById("net_here");
    c.width = 900
    c.height = 450
    ctx=c.getContext("2d");
    @canvas = ctx
    $.ajax
      async: false
      url: 'api/vertices'
      method: 'get'
      dataType: 'json'
      success: (vertices)=>
        for vertex in vertices
          @vertices.push {id: vertex.id, x: vertex.x, y: vertex.y}
    $.ajax
      async: false
      url: 'api/edges'
      method: 'get'
      dataType: 'json'
      success: (edges)=>
        for edge in edges
          @edges.push {
            id: edge.id
            x_1: edge.x_1
            y_1: edge.y_1
            x_2: edge.x_2
            y_2: edge.y_2
            business: edge.business
            t: edge.t
            flow_state: edge.flow_state
            visible: edge.visible
          }

    @init_net()


  draw_vertex: (x, y) ->
    @canvas.beginPath()
    @canvas.arc x, y, 5, 0, 2 * Math.PI, false
    @canvas.stroke()

  draw_edge: (x_1, y_1, x_2, y_2, value, state) ->
    @canvas.beginPath()
    @canvas.moveTo x_1, y_1
    @canvas.lineTo x_2, y_2
    @canvas.fillText(value, (x_1+x_2)/2, (y_1+y_2)/2,  50);
    switch state
      when 'free' then color = '#00FF00'
      when 'congested' then color = '#FFCC00'
      when 'jam' then color = '#FF0000'
    @canvas.strokeStyle = color
    @canvas.stroke()
    return

  init_net: ->
    for vertex in @vertices
      @draw_vertex(vertex.x, vertex.y)
    for edge in @edges
      if edge.visible
        @draw_edge edge.x_1, edge.y_1, edge.x_2, edge.y_2, edge.t, edge.flow_state



  new_edge_first: ->
    return

  new_edge_last: ->
    return
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
          @edges.push {id: edge.id, x_1: edge.x_1, y_1: edge.y_1, x_2: edge.x_2, y_2: edge.y_2}

    @init_net()

  new_vertex: (param1, param2)->
    console.log param1.offsetX
    console.log param1.offsetY
    @canvas = ctx
    ctx.beginPath()
    ctx.moveTo 0, 0
    ctx.lineTo parseInt(param1.offsetX/3), parseInt(param1.offsetY/3)
    ctx.stroke()
    return

  draw_vertex: (x, y) ->
    @canvas.beginPath()
    @canvas.arc x, y, 5, 0, 2 * Math.PI, false
    @canvas.stroke()

  draw_edge: (x_1, y_1, x_2, y_2) ->
    @canvas.beginPath()
    @canvas.moveTo x_1, y_1
    @canvas.lineTo x_2, y_2
    @canvas.stroke()
    return

  init_net: ->
    for vertex in @vertices
      @draw_vertex(vertex.x, vertex.y)
    for edge in @edges
      @draw_edge edge.x_1, edge.y_1, edge.x_2, edge.y_2



  new_edge_first: ->
    return

  new_edge_last: ->
    return
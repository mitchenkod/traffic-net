class @GraphController

  canvas: null
  vertices: []
  edges: []
  routes: []

  new_vertex: (params)->
    console.log params

  constructor: ->
    $('#net_here').click @new_vertex
    c=document.getElementById("net_here");
    c.width = 1200
    c.height = 900
    ctx=c.getContext("2d");
    @canvas = ctx
    $.ajax
      async: false
      url: 'api/vertices'
      method: 'get'
      dataType: 'json'
      success: (vertices)=>
        for vertex in vertices
          @vertices.push {id: vertex.id, x: vertex.x, y: vertex.y, simple_id: vertex.simple_id, marked: vertex.marked}
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
    $.ajax
      async: false
      url: 'api/routes'
      method: 'get'
      dataType: 'json'
      success: (routes)=>
        for route in routes
          @routes.push {id: route.id, edges_ids: [route.edges_ids], vertex_id: route.vertex_id}

    @init_net()


  draw_vertex: (x, y, simple_id, marked) ->
    @canvas.beginPath()
    @canvas.arc x, y, 5, 0, 2 * Math.PI, false
    @canvas.arc(x, y, 10, 0, 2 * Math.PI, false)if marked
    @canvas.fillText(simple_id, x+10, y+10,  50);
    @canvas.stroke()

  draw_edge: (x_1, y_1, x_2, y_2, value, state, business) ->
    @canvas.beginPath()
    @canvas.moveTo x_1, y_1
    @canvas.lineTo x_2, y_2
#    @canvas.fillText(value, (x_1+x_2)/2, (y_1+y_2)/2,  50);
#    @canvas.fillText(business, (x_1+x_2)/2-10, (y_1+y_2)/2+10,  50);
    switch state
      when 'free' then color = '#00FF00'
      when 'congested' then color = '#FFCC00'
      when 'jam' then color = '#FF0000'
    @canvas.strokeStyle = color
    @canvas.stroke()
    return

  init_net: ->
    for vertex in @vertices
      @draw_vertex(vertex.x, vertex.y, vertex.simple_id, vertex.marked)
    for edge in @edges
#      if edge.visible
      @draw_edge edge.x_1, edge.y_1, edge.x_2, edge.y_2, edge.t, edge.flow_state, edge.business
    for route in @routes
      $('.routes_here').append("<span class='route' data-vertex='#{route.vertex_id}' data-edges='#{route.edges_ids}'>route<span><br>")
    $('.routes_here .route').click (event)=>
      edges = $(event.target).data('edges').split(',')
      for edge in edges
        @edge_draw_by_id(edge)
      @vert_draw_by_id($(event.target).data('vertex'))

  edge_draw_by_id: (id)->
    for edge in @edges
      if edge.id == id
        @canvas.beginPath()
        @canvas.moveTo edge.x_1, edge.y_1
        @canvas.lineTo edge.x_2, edge.y_2
        @canvas.strokeStyle = '#FF0066'
        @canvas.stroke()

  vert_draw_by_id: (id)->
    for vert in @vertices
      if vert.id == id
        @canvas.beginPath()
        @canvas.arc vert.x, vert.y, 5, 0, 2 * Math.PI, false
        @canvas.strokeStyle = '#FF0066'
        @canvas.stroke()




  new_edge_first: ->
    return

  new_edge_last: ->
    return
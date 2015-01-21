class @GraphController

  canvas: null

  constructor: ->
    $('#net_here').click @new_vertex


  new_vertex: (param1, param2)->
    console.log param1.offsetX
    console.log param1.offsetY
    c=document.getElementById("net_here");
    ctx=c.getContext("2d");
    ctx.beginPath();
    ctx.moveTo(0,0);
    ctx.lineTo(100,100);
    ctx.stroke();
    return

  new_edge_first: ->
    return

  new_edge_last: ->
    return
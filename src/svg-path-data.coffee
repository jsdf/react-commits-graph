# a canvas like api for building an svg path data attribute
class SVGPathData
  constructor: ->
    @commands = []
  toString: ->
    @commands.join(' ')
  moveTo: (x,y) ->
    @commands.push "M #{x},#{y}"
  lineTo: (x,y) ->
    @commands.push "L #{x},#{y}"
  closePath: (x,y) ->
    @commands.push "Z"
  bezierCurveTo: (cp1x, cp1y, cp2x, cp2y, x, y) ->
    @commands.push "C #{cp1x}, #{cp1y}, #{cp2x}, #{cp2y}, #{x}, #{y}"
  quadraticCurveTo: (cp1x, cp1y,  x, y) ->
    @commands.push "Q #{cp1x}, #{cp1y}, #{x}, #{y}"

module.exports = SVGPathData
_ = require "underscore"

{Variable, EQ, GE, Strength}  = require "../../core/layout/solver"
Model = require "../../model"
Range1d = require "../ranges/range1d"

class LayoutBox extends Model
  type: 'LayoutBox'

  nonserializable_attribute_names: () ->
    super().concat(['layout_location'])

  get_edit_variables: () ->
    editables = []
    editables.push({edit_variable: @_top, strength: Strength.strong})
    editables.push({edit_variable: @_left, strength: Strength.strong})
    editables.push({edit_variable: @_width, strength: Strength.strong})
    editables.push({edit_variable: @_height, strength: Strength.strong})
    return editables

  get_constraints: () ->
    constraints = []
    constraints.push(GE(@_top))
    constraints.push(GE(@_bottom))
    constraints.push(GE(@_left))
    constraints.push(GE(@_right))
    constraints.push(GE(@_width))
    constraints.push(GE(@_height))
    constraints.push(EQ(@_left, @_width, [-1, @_right]))
    constraints.push(EQ(@_bottom, @_height, [-1, @_top]))
    return constraints

  _doc_attached: () ->
    @_top = new Variable('top')
    @_left = new Variable('left')
    @_width = new Variable('width')
    @_height = new Variable('height')
    @_right = new Variable('right')
    @_bottom = new Variable('bottom')

    @register_property('height', @_get_var, false)
    @register_property('width', @_get_var, false)
    @register_property('right', @_get_var, false)
    @register_property('left', @_get_var, false)
    @register_property('top', @_get_var, false)
    @register_property('bottom', @_get_var, false)

    @_h_range = new Range1d.Model({start: @get('left'), end: @get('left') + @get('width')})
    @register_property('h_range',
        () =>
          @_h_range.set('start', @get('left'))
          @_h_range.set('end',   @get('left') + @get('width'))
          return @_h_range
      , false)
    @add_dependencies('h_range', this, ['left', 'width'])

    @_v_range = new Range1d.Model({start: @get('bottom'), end: @get('bottom') + @get('height')})
    @register_property('v_range',
        () =>
          @_v_range.set('start', @get('bottom'))
          @_v_range.set('end',   @get('bottom') + @get('height'))
          return @_v_range
      , false)
    @add_dependencies('v_range', this, ['bottom', 'height'])

  _get_var: (prop_name) ->
    return @['_' + prop_name].value()

module.exports =
  Model: LayoutBox
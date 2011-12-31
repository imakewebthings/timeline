every = (ms, callback) -> setInterval callback, ms

class Timeline
  # Statics
  @defaults:
    frequency: 100
    length: 0
  
  # "Private" things
  _lastPosition: 0
  _position: 0
  _timer: -1
  _previousTick: 0
  
  _createTick: ->
    clearInterval @_timer
    @_timer = every @_options.frequency, @_onTick
  
  _onTick: =>
    now = (new Date).getTime()
    @_updatePositions now
    @_triggerMarkers()
    @_previousTick = now
    @trigger 'tick'
    @_checkForEnd()
    
  _updatePositions: (now) ->
    @_lastPosition = @_position
    @_position += now - @_previousTick
  
  _triggerMarkers: ->
    for marker in @markers
      marker.backward() if @_lastPosition > marker.time >= @_position
      marker.forward() if @_lastPosition <= marker.time < @_position
  
  _checkForEnd: ->
    if @_position >= @_options.length
      @_position = @_options.length
      @pause()
      @trigger 'end'
      
  # "Public" things
  playing: off
  markers: []
  
  constructor: (options) ->
    @_options = {}
    @_options[key] = val for key, val of Timeline.defaults
    @_options[key] = val for key, val of options
    @_events = {}
  
  length: (ms) ->
    if ms?
      @_options.length = ms
      this
    else
      @_options.length
    
  frequency: (ms) ->
    if ms?
      @_options.frequency = ms
      this
    else
      @_options.frequency
    
  position: (ms) ->
    if ms?
      ms = @_options.length if ms > @_options.length
      ms = 0 if ms < 0
      @_lastPosition = @_position
      @_position = ms
      @_triggerMarkers()
      @trigger 'tick'
      @_checkForEnd()
      this
    else
      @_position
    
  play: ->
    unless @playing
      @playing = on
      @_previousTick = (new Date).getTime()
      @_createTick()
      @trigger 'play'
    this
  
  pause: ->
    if @playing
      @playing = off
      clearInterval @_timer
      @trigger 'pause'
    this
  
  on: (event, callback) ->
    @_events[event] = [] unless @_events[event]
    @_events[event].push callback
    this
    
  off: (event, callback) ->
    if @_events[event]? and callback?
      @_events[event] = (cb for cb in @_events[event] when cb isnt callback)
    else
      @_events[event] = []
    this
    
  trigger: (event, args...) ->
    if @_events[event]?
      callback.apply this, args for callback in @_events[event]
    this
    
if module then module.exports = Timeline else @Timeline = Timeline
  
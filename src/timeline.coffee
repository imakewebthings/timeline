# setInterval rearranged for CoffeeScript goodness
every = (ms, callback) -> setInterval callback, ms

###
Timeline: A generic event timeline for node.js or the browser.

Copyright (c) 2011-2012 Caleb Troughton
Licensed under the MIT license.
https://raw.github.com/imakewebthings/timeline/master/MIT-license.txt
### 
class Timeline
  # Statics!
  @defaults:
    frequency: 100
    length: 0


  # Begin "private" things.  Not really private, just using the lazy
  # underscore naming to denote their undocumented, internal status.
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
    @_position = @_options.length if @_position > @_options.length

  _triggerMarkers: ->
    for marker in @markers
      marker.backward() if @_lastPosition > marker.time >= @_position
      marker.forward() if @_lastPosition <= marker.time < @_position

  _checkForEnd: ->
    if @_position >= @_options.length
      @_position = @_options.length
      @pause()
      @trigger 'end'



  # Begin "public" things
  playing: off

  # Markers are objects with three properties. To add markers, just
  # put them in this array.
  #
  # time: Number in milliseconds where this marker should live on
  #       the timeline
  # forward: Function that fires when the timeline moves forward
  #          through the marker.
  # backward: Function that fires when the timeline moves backward
  #           through the marker.
  markers: []


  # Creates a new Timeline object. Extends the defaults with the
  # values in the options parameter if passed in.
  constructor: (options) ->
    @_options = {}
    @_options[key] = val for key, val of Timeline.defaults
    @_options[key] = val for key, val of options
    @_events = {}


  # If no parameters are given, this returns the total length of
  # the timeline in milliseconds.  If a number is passed in, it
  # sets the total length and returns the Timeline for chaining.
  length: (ms) ->
    if ms?
      @_options.length = ms
      this
    else
      @_options.length


  # If no parameters are given, this returns the frequency at
  # which the timeline emits tick events in milliseconds. If a
  # number is passed in, it sets the frequency and returns the
  # Timeline for chaining.
  frequency: (ms) ->
    if ms?
      @_options.frequency = ms
      this
    else
      @_options.frequency


  # If no parameters are given, this returns the current position
  # in the timeline. If a number is passed in, the timeline seeks
  # to the new position and returns the Timeline for chaining. This
  # jump will always produce a tick, and may emit an end event if
  # appropriate.  If the number passed in is below 0 or above the
  # total length the method will seek to the closest possible value
  # (0 and length, respectively).
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


  # Begins playing the Timeline. Starts emitting ticks every
  # "frequency" milliseconds and trigger markers as it goes.
  # Emits a play event.
  play: ->
    unless @playing
      @playing = on
      @_previousTick = (new Date).getTime()
      @_createTick()
      @trigger 'play'
    this


  # Pauses the Timeline. Emits a pause event.
  pause: ->
    if @playing
      @playing = off
      clearInterval @_timer
      @trigger 'pause'
    this


  # Binds the callback to the event, where "event" is a string
  # and "callback" is a function.
  on: (event, callback) ->
    @_events[event] = [] unless @_events[event]
    @_events[event].push callback
    this


  # If callback is passed in, this unbinds that function from
  # the event. If no callback is given, all callbacks are unbound.
  off: (event, callback) ->
    if @_events[event]? and callback?
      @_events[event] = (cb for cb in @_events[event] when cb isnt callback)
    else
      @_events[event] = []
    this


  # Triggers all callbacks on the given event. Any extra arguments
  # are passed on to the callbacks.
  trigger: (event, args...) ->
    if @_events[event]?
      callback.apply this, args for callback in @_events[event]
    this

if module? then module.exports = Timeline else @Timeline = Timeline
  
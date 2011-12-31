should = require 'should'
Timeline = require '../lib/timeline'

# utils
after = (ms, callback) -> setTimeout callback, ms
every = (ms, callback) -> setInterval callback, ms

describe 'Timeline', ->
  describe '#constructor()', ->
    line = undefined
    
    beforeEach ->
      line = new Timeline
    
    it 'should create a new Timeline object', ->
      line.should.be.instanceof Timeline
    
    it 'should use the default options', ->
      line.frequency().should.eql Timeline.defaults.frequency
      line.length().should.eql Timeline.defaults.length
      
  describe '#constructor(options)', ->
    it 'should extend the default options', ->
      line = new Timeline
        frequency: 50
        length: 1000
      line.frequency().should.eql 50
      line.length().should.eql 1000
      
  describe '#length()', ->
    it 'should return the length of the timeline', ->
      line = new Timeline length:1000
      line.length().should.equal 1000
      
  describe '#length(ms)', ->
    line = undefined
    
    beforeEach ->
      line = new Timeline
      
    it 'should change the length of the timeline', ->
      line.length 500
      line.length().should.equal 500
    
    it 'should return the timeline object', ->
      line.should.equal line.length 500
      
  describe '#frequency()', ->
    it 'should return the frequency of ticks', ->
      line = new Timeline frequency:200
      line.frequency().should.equal 200
      
  describe '#frequency(ms)', ->
    it 'should set the frequency', ->
      line = new Timeline
      line.frequency 300
      line.frequency().should.equal 300
      
    it 'should tick at the new frequency', (done) ->
      count = 0
      line = new Timeline
      line.frequency 300
      line.on 'tick', ->
        ++count
      line.play()
      after 400, ->
        line.pause
        count.should.equal 1
        done()
    
    it 'should return the timeline object', ->
      line = new Timeline
      line.should.equal line.frequency 300
      
  describe '#position()', ->
    it 'should return the current time in the timeline', ->
      line = new Timeline length:1000
      line.position().should.equal 0
      line.position 300
      line.position().should.equal 300
      
  describe '#position(ms)', ->
    line = undefined
    
    beforeEach ->
      line = new Timeline length:1000

    it 'should seek to the new time in the timeline', ->
      line.position 200
      line.position().should.equal 200
      
    it 'should trigger any markers between the old and new positions', ->
      hit = false
      line.markers.push
        time: 100
        forward: ->
          hit = true
        backward: ->
          hit = false
      
      line.position 200
      hit.should.be.true
      
    it 'should trigger a single tick event', ->
      count = 0
      line.on 'tick', ->
        ++count
      line.position 200
      count.should.equal 1
      
    it 'should seek to 0 if passed a negative number', ->
      line.position -5
      line.position().should.equal 0
      
    it 'should seek to the end if passed a number > length', ->
      line.position 999999
      line.position().should.equal line.length()
      
    it 'should fire the end event if seeked to the end', ->
      hit = false
      line.on 'end', ->
        hit = true
      line.position 999999
      hit.should.be.true
      
    it 'should return the timeline object', ->
      line.should.equal line.position 200
      
  describe '@markers', ->
    line = undefined
    count = 0
    
    beforeEach ->
      count = 0
      line = new Timeline length: 1000
      line.markers.push
        time: 100
        forward: ->
          ++count
        backward: ->
          --count
      
    it 'should fire the forward function seeking ahead', ->
      line.position 200
      count.should.equal 1
      
    it 'should fire the backward function seeking behind', ->
      line.position 200
      line.position 50
      count.should.equal 0
      
    it 'should fire nothing if the marker is removed', ->
      line.markers = []
      line.position 200
      count.should.equal 0
      
  describe '#play()', ->
    it 'should set the playing flag to true', ->
      line = new Timeline length:1000
      line.play()
      line.playing.should.be.true
      
    it 'should fire the play event', ->
      line = new Timeline length:1000
      hit = false
      line.on 'play', ->
        hit = true
      line.play()
      hit.should.be.true
    
    it 'should begin ticking', (done) ->
      count = 0
      line = new Timeline length:1000
      line.on 'tick', ->
        ++count
      line.play()
      after 510, ->
        count.should.be.above 2
        done()
        
    it 'should return the timeline object', ->
      line = new Timeline length:1000
      line.should.equal line.play()
      
    it 'should trigger an end event and pause when end is reached', ->
      line = new Timeline length:200
      count = 0
      line.on 'end', ->
        ++count
      line.on 'pause', ->
        ++count
      line.play()
      after 300, ->
        count.should.equal 2
      
  describe '#pause()', ->
    it 'should set the playing flag to false', ->
      line = new Timeline length:1000
      line.play()
      line.pause()
      line.playing.should.be.false
    
    it 'should fire the pause event', ->
      hit = false
      line = new Timeline length:1000
      line.on 'pause', ->
        hit = true
      line.play()
      line.pause()
      hit.should.be.true
    
    it 'should stop ticking', (done) ->
      count = 0
      line = new Timeline length:1000
      line.play()
      line.pause()
      line.on 'tick', ->
        ++count
      after 300, ->
        count.should.equal 0
        done()
    
    it 'should return the timeline object', ->
      line = new Timeline length:1000
      line.should.equal line.pause()
  
  describe '#on(event, callback)', ->
    line = undefined
    
    beforeEach ->
      line = new Timeline
      
    it 'should register the event callback', ->
      hit = false
      line.on 'event', ->
        hit = true
      line.trigger 'event'
      hit.should.be.true
    
    it 'should return the timeline object', ->
      returning = line.on 'event', ->
      line.should.equal returning
    
  describe '#off(event)', ->
    line = undefined
    count = 0
    
    beforeEach ->
      line = new Timeline
      line.on 'event', ->
        ++count
      line.on 'event', ->
        ++count
      
    it 'should unregister all callbacks associated with event', ->
      line.off 'event'
      line.trigger 'event'
      count.should.equal 0
    
    it 'should return the timeline object', ->
      line.should.equal line.off 'event'
      
  describe '#off(event, callback)', ->
    it 'should unregister the specified callback', ->
      line = new Timeline
      count1 = count2 = 0
      callback1 = ->
        ++count1
      callback2 = ->
        ++count2
      line.on 'event', callback1
      line.on 'event', callback2
      line.off 'event', callback1
      line.trigger 'event'
      count1.should.equal 0
      count2.should.equal 1
      
  describe '#trigger(event, args...)', ->
    line = undefined
    hit = false
    arg = undefined
    
    beforeEach ->
      line = new Timeline
      hit = false
      line.on 'event', (anything) ->
        hit = true
        arg = anything
    
    it 'should trigger all callbacks bound to the event', ->
      line.trigger 'event'
      hit.should.be.true
    
    it 'should pass arguments to the callbacks', ->
      line.trigger 'event', 1
      arg.should.equal 1
      
    it 'should return the timeline object', ->
      line.should.equal line.trigger 'event'
    
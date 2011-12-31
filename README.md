## Installation

Node:

```sh
npm install timeline
```

```coffee
Timeline = require 'timeline'
```

Browser:

```html
<script src="/path/to/timeline.js"></script>
```

## Usage

To create a timeline using the default options:

```coffee
timeline = new Timeline
```

You can also pass in options:

```coffee
timeline = new Timeline
  length: 5000
  frequency: 250
```

The defaults are:

```coffee
length: 0
frequency: 100
```

`length` is the total length of the timeline. `frequency` is how often `tick` events are fired when the timeline is playing. All values are in milliseconds.

## Markers

A Timeline object contains an Array of markers. Markers are objects with three properties:

<dl>
  <dt>time</dt>
  <dd>The time in milliseconds on the timeline where the marker should live.</dd>
  <dt>forward</dt>
  <dd>The function to execute when moving forward in time through the marker.</dd>
  <dt>backward</dt>
  <dd>The function to execute when moving backward in time through the marker.</dd>
</dl>

```coffee
timeline.markers.push
  time: 500
  forward: ->
    $('.elements').show()
  backward: ->
    $('.elements').hide()
```

## Methods

All getters return the expected value. Every other method returns the Timeline object for chaining.

<dl>
  <dt>play()</dt>
  <dd>Begins playing the timeline, triggering markers as it goes.</dd>
  
  <dt>pause()</dt>
  <dd>Stops playing the timeline.</dd>
  
  <dt>length()</dt>
  <dd>Returns the length of the timeline.</dd>
  
  <dt>length(ms)</dt>
  <dd>Sets the length of the timeline to `ms`.</dd>
  
  <dt>frequency()</dt>
  <dd>Returns the frequency.</dd>
  
  <dt>frequency(ms)</dt>
  <dd>Sets the frequency to `ms`.</dd>
  
  <dt>position()</dt>
  <dd>Returns the current position of the timeline.</dd>
  
  <dt>position(ms)</dt>
  <dd>Jumps to the new position at `ms`.</dd>
</dl>

## Events

Timelines also have three methods for events:

<dl>
  <dt>on(event, callback)</dt>
  <dd>Binds the `callback` function to the event.</dd>
  <dt>off(event[, callback])</dt>
  <dd>Unbinds event callbacks.  If a callback is passed in as the second argument, only that callback is unbound. If there is no second argument, all callbacks for that event are unbound.</dd>
  <dt>trigger(event, args...)</dt>
  <dd>Triggers all callbacks bound to the event. Any extra parameters are passed as parameters to the callbacks.</dd>
</dl>

Timelines emit these events:

<dl>
  <dt>play</dt>
  <dd>Triggered whenever a timeline starts playing.</dd>
  <dt>pause</dt>
  <dd>Triggered whenever a timeline pauses.</dd>
  <dt>end</dt>
  <dd>Triggered if the timeline hits the end.</dd>
  <dt>tick</dt>
  <dd>Triggered every `frequency` milliseconds while a timeline is playing, and once every time `position(ms)` is used, regardless of whether the timeline is playing or not.</dd>
</dl>

```coffee
timeline = new Timeline length:4000
timeline.on 'tick', ->
  $('.current-time').text timeline.position()
```

## Other Properties

<dl>
  <dt>playing</dt>
  <dd>True if the timeline is playing, false otherwise.</dd>
</dl>

## Development + Tests

Tests are written in CoffeeScript using [Mocha](http://visionmedia.github.com/mocha/) and [should.js](https://github.com/visionmedia/should.js). To run them:

1. Clone the repository
2. `npm install`
3. `make test`

## License

[MIT](https://raw.github.com/imakewebthings/timeline/master/MIT-license.txt).
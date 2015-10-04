var sourceEl = document.querySelector("video")
var destEl = document.querySelector("#finder")
var screenshotDimensions = [80, 104]

var emotions = [
  [50, "happiness"]
]

Animator = function(events, sourceEl, destEl) {
  this.events = events
  this.currentIndex = 0
  this.sourceEl = sourceEl
  this.destEl = destEl
  console.log("created player")
}

Animator.prototype.blinkSource = function(cb) {
  $(this.sourceEl).fadeOut(500).fadeIn(500, cb)
}

Animator.prototype.performNext = function() {
  var next = this.events[this.currentIndex]
  var canvasImage = document.createElement('canvas')
  //canvasImage.width =

  


  
  var self = this

  this.blinkSource(function () {
    // ...

    
    
  })
}

Animator.prototype.loop = function() {
  if (this.sourceEl.currentTime >= this.events[this.currentIndex]) {
    this.performNext()
  }

  if (this.currentIndex < this.events.length) {
    setTimeout(this.loop, 500)
  }
}

var animator = Animator()
animator.loop()

class Loader
  constructor: ->

  monkeyQuotes =
    ["Man, these monkeys are slow today!"
    "We better get some more bananas..."
    "Ever seen monkeys in the cloud? - We neither."
    "Working, working, banana."
    "Guess the monkeys are on strike."
    "Throwing more bananas into the ring."]

  initCanvasLoader: ->
    console.log 'canvas'
    cl = new CanvasLoader('loader')
    cl.setColor '#ffffff' # default is '#000000'
    cl.setDiameter 20 # default is 40
    cl.setDensity 15 # default is 40
    cl.setRange 0.7 # default is 1.3
    cl.setSpeed 1 # default is 2
    cl.setFPS 12 # default is 24
    cl.show()  # Hidden by default
    
  calculateStyle: ->
    t = $('body')
    $('.overlay').css({
      top: t.offset().top+40,
      height: t.outerHeight()})

  getRandomMonkeyQuote: ->
    monkeyQuotes[Math.floor(Math.random() * monkeyQuotes.length)]

  spawnWindow: ->
    if $('.monkey').length
      $(".monkey").html("<span id='text'>" + loader.getRandomMonkeyQuote() + "</span>")
    else
      $("#canvasLoader").clone().html("<span id='text'>" + loader.getRandomMonkeyQuote() + "</span>").addClass("monkey").appendTo(".overlay")
    $(".monkey").css('width', $(".monkey #text").width() + 10 )

  load: ->
    @initCanvasLoader()
    @calculateStyle()
    $('.btn').addClass('disabled')
    $('#canvasLoader').append("<span id='text'> Please wait, untill our trained monkeys finished preparing your data...</span>")
    $(".overlay").fadeIn()
    setInterval(@spawnWindow, 5000)
    @getRandomMonkeyQuote()

@.loader = new Loader()
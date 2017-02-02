$ ->
  footerPosition = ->
    console.log 'SUCCESS'
    windowHeight = $(window).outerHeight()
    bodyHeight = $('body').outerHeight()

    if $('body').hasClass('footer-position')
      bodyHeight = $('body').outerHeight() + $('#footer').outerHeight()

    if windowHeight > bodyHeight
      $('footer, body').addClass('footer-position')
    else
      $('footer, body').removeClass('footer-position')

  # Execute on page load
  #footerPosition()

  #setTimeout (->
  #  footerPosition()
  #), 2500

  #$(window).resize ->
  #  footerPosition()

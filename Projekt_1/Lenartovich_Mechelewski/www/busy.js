setInterval(function(){
  if ($('#currentTime').text()=='') {
    setTimeout(function() {
      if ($('#test').text()=='') {
        $('div.busy').show()
      }
    }, 1000)
  } else {
    $('div.busy').hide()
  }
}, 100)
setInterval(function(){
  if ($(":root").hasClass("shiny-busy")) {
        $('div.busy').show();
  } else {
    $('div.busy').hide();
  }
}, 100)
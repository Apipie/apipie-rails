$(document).ready(function() {
  $('#details a').click(function(e) {
    e.preventDefault();
    $(this).tab('show')
  });

  if (typeof prettyPrint == 'function') {
    $('pre.ruby').addClass('prettyprint lang-rb');
    prettyPrint();
  }
});

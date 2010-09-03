function prepareToolTip() {
     
    $('.vote-power-ubox').each(function() {
        $(this).tooltip({
            relative : true
        });
    });
    $('.tracking-count').each(function() {
        $(this).tooltip({
            relative : true
        });
    });
    $('.power-points').each(function() {
        $(this).tooltip({
            relative : true
        });
    });
}
$(document).ready(function() {
    setTimeout(prepareToolTip, 500)
    $(document).bind('ajaxComplete', function() {
        prepareToolTip();
    });
    
    if ($('.load-widget-link').length > 0) {
        $('.load-widget-link').each(function() {
            $.ajax({
                type: 'GET',
                url : $(this).attr('href'),
                dataType : 'script',
                global:false,
                context:$(this),
                success : function() {
                 $(this).parent('div').slideDown('slow', function(){});
                }
            });
        });
    }
})


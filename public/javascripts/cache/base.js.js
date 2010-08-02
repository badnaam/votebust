var showMenu = function(ev) {
    //get the position of the placeholder element
    var pos = $("#home_nav a").offset();
    var width = $("#home_nav").width();
    var height = $("#home_nav a").outerHeight();
    //show the menu directly over the placeholder
    $("#cat_menu").css( {
        "left": (pos.left) + "px",
        "top":(pos.top + height) + "px"
    });
    $('#cat_nav a').toggleClass('hover-nav');
    $("#cat_menu").toggle('fast');
}

$(document).ready(function(){
    $('#close_cat_menu').click(function(){
        $('#cat_nav a').toggleClass('hover-nav');
        $("#cat_menu").toggle('fast');
    });
    
    $('#new_vote_btn').button({
        icons:{
            primary:'ui-icon-lightbulb'
        }
    });
    $('#search_term').focus(function(){
        $(this).val('');
    });
    $("#search_form a").click(function() {
        $(this).parents().filter("form").trigger("submit");
    });

    /**$('#main_login_link').button({
        icons:{
            primary:'ui-icon-key'
        }
    });
    $('#main_sign_up_link').button({
        icons:{
            primary:'ui-icon-notice'
        }
    });
    $('#main_new_vote_link').button({
        icons:{
            primary:'ui-icon-plus'
        }
    });
    $('#main_profile_link').button({
        icons:{
            primary:'ui-icon-contact'
        }
    });**/

    $('#search_button').button({
        icons:{
            primary:'ui-icon-search'
        },
        text:false
    });
    $("#cat_nav").bind('click', function(){
        showMenu();
        return false;
    });
});

//document.observe("dom:loaded", function() {
//    $('loading').hide();
//    if ($$('.submit-link-button') != null) {
//        elem = $$('.submit-link-button').first();
//        Event.observe(elem, 'click', function(event) {
//            this.up('form').submit();
//        });
//    }
//    Ajax.Responders.register({
//        onCreate: function() {
//            new Effect.Opacity('main_container', {
//                from: 1.0,
//                to: 0.3,
//                duration: 0.7
//            });
//            //            new	Effect.toggle('loading', 'appear');
//            $('loading').show();
//
//        },
//        onComplete: function() {
//            new Effect.Opacity('main_container', {
//                from: 0.3,
//                to: 1,
//                duration: 0.7
//            });
//            //            new	Effect.toggle('loading', 'appear');
//            $('loading').hide();
//        }
//    });

//    var container = $(document.body)
//
//    container.observe('click', function(e) {
//        var el = e.element()
//        if (el.match('.pagination a')) {
//            //el.up('.pagination').insert(createSpinner())
//            new Ajax.Request(el.href, {
//                method: 'get'
//            })
//            e.stop()
//        }
//    });

//});

function showLoading(elem) {
    //$(elem).fadeIn('slow');
    $(elem).animate({opacity:1.0}, 'slow', function(){});
    //$(elem).parent().animate({
    $(elem).next('div').animate({
        opacity: 0.3
    }, 'slow', function() {
        // Animation complete.
        });
}

function hideLoading(elem) {
    //$(elem).fadeOut('slow');
    $(elem).animate({opacity:0.0}, 'slow', function(){});
    //$(elem).parent().animate({
    $(elem).next('div').animate({
        opacity: 1.0
    }, 'slow', function() {
        // Animation complete.
        });
}

$(function () {
    $('.pagination a').live("click", function () {
        showLoading('#com_prog_loading');
        $.get(this.href, null, function (data) {
           /** $('#com_prog_loading').fadeOut('slow');
            $('#com_prog_loading').parent().animate({
                opacity: 1.0
            }, 'slow', function() {
                // Animation complete.
                }); **/
            hideLoading('#com_prog_loading')
        }, 'script');
        //       $.get(this.href, null, null, 'script');
        return false;
    });

    //loading
    // $('#loading').hide();
    
    /**$("#loading").bind("ajaxStart", function(){
        $(this).fadeIn('slow');
        $('#main_container').animate({
            opacity: 0.3
        }, 'slow', function() {
            // Animation complete.
            });

    }).bind("ajaxStop", function(){
        $(this).fadeOut('slow');
        $('#main_container').animate({
            opacity: 1
        }, 'slow', function() {
            // Animation complete.
            });
    });**/
    $("#gg").bind("ajaxStart", function(){
        $(this).fadeIn('slow');
        $(this).parent().animate({
            opacity: 0.3
        }, 'slow', function() {
            // Animation complete.
            });

    }).bind("ajaxStop", function(){
        $(this).fadeOut('slow');
        $(this).parent().animate({
            opacity: 1
        }, 'slow', function() {
            // Animation complete.
            });
    });
});
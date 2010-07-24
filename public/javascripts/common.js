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
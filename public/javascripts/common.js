var showMenu = function(ev) {
    //get the position of the placeholder element
    var pos = $("#home_nav a").offset();
    var width = $("#home_nav").width();
    var height = $("#home_nav a").outerHeight();
    //show the menu directly over the placeholder
    $("#cat_menu").css( {
        "left": (pos.left) + "px",
        "top":(pos.top + height) + "px"
    } );
    $("#cat_menu").toggle('slow');
}

$(document).ready(function(){
    $('#new_vote_btn').button({
        icons:{
            primary:'ui-icon-lightbulb'
        }
    });
$("#search_form a").click(function() {
    $(this).parents().filter("form").trigger("submit");
});

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
 var $j = jQuery.noConflict();
var showMenu = function(ev) {
    //get the position of the placeholder element
    var pos = $j("#home_nav a").offset();
    var width = $j("#home_nav").width();
    var height = $j("#home_nav a").outerHeight();
    //show the menu directly over the placeholder
    $j("#cat_menu").css( {
        "left": (pos.left) + "px",
        "top":(pos.top + height) + "px"
    } );
    $j("#cat_menu").toggle('slow');
}

$j(document).ready(function(){
   /** $j('#new_vote_btn').button({
        icons:{
            primary:'ui-icon-lightbulb'
        }
    });**/
    
    $j("#search_form a").click(function() {
        $j(this).parents().filter("form").trigger("submit");
    });

    $j('#search_button').button({
        icons:{
            primary:'ui-icon-search'
        },
        text:false
    });
    $j("#cat_nav").bind('click', function(){
        showMenu();
        return false;
    });
});
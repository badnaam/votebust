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
    $j('#cat_nav a').toggleClass('hover-nav');
    $j("#cat_menu").toggle('fast');
}

function showLoading(elem) {
    $j(elem).show();
    $j(elem).parent('div').animate({
        opacity: 0.3
    }, 'slow', function() {
        // Animation complete.
        });
}

function hideLoading(elem) {
    $j(elem).hide();
    //alert($j(elem).parent('div').html());
    $j(elem).parent('div').animate({
        opacity: 1.0
    }, 'slow', function() {
        // Animation complete.
        });
}

function checkVoteSelected() {
    oneChecked = false
    $j(':radio', '#vote_form').each(function() {
        if (this.checked == true) {
            $j('#vote_form').submit();
            oneChecked = true
        }
    });
    if (oneChecked == false) {
        alert('Please select a vote option.');
    }
    return false;
}
    
$j(document).ready(function(){
    $j('.pagination a').live("click", function () {
        showLoading('#com_prog_loading');
        $j.get(this.href, null, function (data) {
            hideLoading('#com_prog_loading')
        }, 'script');
        return false;
    });
    $j('#close_cat_menu').click(function(){
        $j('#cat_nav a').toggleClass('hover-nav');
        $j("#cat_menu").toggle('fast');
    });
    
    $j('#search_term').focus(function(){
        $j(this).val('');
    });
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
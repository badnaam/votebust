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

function showLoading(elem) {
    $(elem).show();
    $(elem).parent('div').animate({
        opacity: 0.3
    }, 'slow', function() {
        // Animation complete.
        });
}

function hideLoading(elem) {
    $(elem).hide();
    $(elem).parent('div').animate({
        opacity: 1.0
    }, 'slow', function() {
        // Animation complete.
        });
}
$(document).ready(function(){
    $('.pagination a').live("click", function () {
        showLoading('#com_prog_loading');
        /**$.get(this.href, null, function (data) {
            hideLoading('#com_prog_loading')
        }, 'script');**/
        $.ajax({type : 'GET', url : this.href,
            complete : function() {
                hideLoading('#com_prog_loading')
            },dataType : 'script' })
        return false;
    });
    
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
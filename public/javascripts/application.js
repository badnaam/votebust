function handleCommentText(maxLength) {
    $('#comment_body').keyup(
    function() {
        update_chars_left(maxLength, $('#comment_body')[0], $('#limit_status'));
    });
}

function showProgress(elem) {
    $(elem).show();
}
function hideProgress(elem) {
    $(elem).hide();
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
function update_chars_left(max_len, target_input, display_element) {
    var text_len = target_input.value.length;
    if (text_len >= max_len) {
        target_input.value = target_input.value.substring(0, max_len); // truncate
        display_element.html("0 characters left");
    } else {
        display_element.html((max_len - text_len) + " characters left");
    }
}
function setVotingCounter(inter) {
    var resetVoteCount  = setInterval(function() {
        $('#vote_count').val(0);
        $('#flash_messages').removeClass('error').empty();
    }, inter);
}

function handleVoting(id) {
    var sel_list = $("li:has(a.cancel)", '#vote_items_list_voted');
    if (sel_list.length == 0) {
        //no selected list this is a fresh vote
        $("li[id^='v-item-']", "#vote_items_list_voted").each(function() {
            //loop through the lists
            anchor = $(this).children('a');
            if (anchor.attr('id') != id) {
                //if not the selected response
                //get the text
                txt = anchor.text();
                anchor.remove();
                $(this).text(txt);
            } else {
                //if selected element, remove vote class
                anchor.removeClass('vote').addClass('cancel');
                //change the span icon
                anchor.children('span').removeClass('ui-icon-check').addClass('ui-icon-close');
            }
        });
    } else {
        var selected_id = sel_list.children('a').attr('id');
        var txt = sel_list.text();
        if (selected_id != id) {
            sel_list.empty().text(txt);
            var new_selection = $('#v-item-' + id);
            var new_text = new_selection.text();
            new_selection.empty().append(makeCancelElement(id, new_text));
        }
    }
    $('#vote_items_list_voted').show('slow');
    $('#vote_items_list_unvoted').hide('slow');
}
function makeCancelElement(id, txt) {
    var cancel_link = $("<a></a>").attr('class', 'cancel take-action').attr('id', id).attr('href', '#');
    var cancel_button = $('<span></span>').attr('class', 'ui-icon ui-icon-close vote-icon');
    var cancel_element = cancel_link.append(cancel_button).append(txt);
    return cancel_element;
}



function prepareToolTip() {
    $('.vote-power-ubox').each(function() {
        $(this).tooltip({
            relative : true
        });
    });
    $('.tracking-count').each(function() {
        $(this).tooltip({
            relative : true,
            position : 'center left'
        });
    });
    $('.power-wrapper').each(function() {
        $(this).tooltip({
            relative : true,
            position : 'center left'
        });
    });
    $('.most-voted').each(function() {
        $(this).tooltip({
            relative : true,
            position : 'center left'
        });
    });
    $('.most-tracked').each(function() {
        $(this).tooltip({
            relative : true,
            position : 'center left'
        });
    });
}

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

$(document).ready(function() {
    setTimeout(prepareToolTip, 500)

    $(document).bind('ajaxComplete', function() {
        prepareToolTip();
    });

    /****For comments**/
    $('#comment_submit').button({
        icons:{
            primary:'ui-icon-comment'
        }
    }).click(function() {
        $('#new_comment').submit();
        return false;
    });

    $('#new_comment').submit(function (){
        showLoading('#com_submit_loading')
        $.post($(this).attr('action'), $(this).serialize(), function(data) {
            hideLoading('#com_submit_loading');
        }, "script");
        return false;
    });

    /**End For Comments **/
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
    
});

/** $('.pagination a').live("click", function () {
        showLoading('#com_prog_loading');
        $.ajax({
            type : 'GET',
            url : this.href,
            complete : function() {
                hideLoading('#com_prog_loading')
            },
            dataType : 'script'
        })
        return false;
    });**/
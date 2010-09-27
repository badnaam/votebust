function configureVoteForm(maxVoteTopicHeaderLength, maxVoteTopicLength, maxVoteItemLength) {
    $('.vote-form-more-details').live('click', function() {
        $('.vote-form-details').toggle('');
        return false;
    });
    $('#vote_topic_header').keyup(
        function() {
            update_chars_left(maxVoteTopicHeaderLength , $('#vote_topic_header')[0],  $('#vote_topic_header').next('p'));
        });
    $('#vote_topic_topic').keyup(
        function() {
            update_chars_left(maxVoteTopicLength , $('#vote_topic_topic')[0],  $('#vote_topic_topic').next('p'));
        });

    $("input[id^='vote_topic_vote_items_attributes']").each(function() {
        $(this).keyup(function() {
            update_chars_left(maxVoteItemLength , $(this)[0],  $(this).next('p'));
        })
    });

    /**$("input#vote_topic_header").blur(function(){
        value = $("input#vote_topic_header").val()
        if (value != "") {
            $.get(autoCompUrl, {
                term : value
            }, function(){});
        }
    });**/

    $('#vote_submit').button({
        icons:{
            primary:'ui-icon-circle-check'
        }
    }).click(function(){
        $('#vote_topic_form').submit();
        return false;
    });

    /** for ajax submit **/
    $('#vote_topic_form').submit(function (){
        $.ajax({
            type: 'POST',
            dataType : 'script',
            url : $(this).attr('action'),
            data : $(this).serialize(),
            global : false,
            beforeSend : function() {
                showLoading("#form_loading")
            },
            complete : function() {
                hideLoading("#form_loading")
            }
        });
        /**$.post($(this).attr('action'), $(this).serialize(), function(data) {
        //hideLoading('#interest_loading');
      }, "script");**/
        return false;
    });
}

var ModalVoteForm = {
    init: function(){
        $("a[rel='#vote_overlay']").each(function(){
            //alert($(this).attr('href'));
            $(this).overlay({
                closeOnClick: false,
                target: '#vote_overlay',
                fixed: false,
                onBeforeLoad: function() {
                    // grab wrapper element inside content
                    var wrap = this.getOverlay().find(".contentWrap");
                    // load the page specified in the trigger
                    wrap.load(this.getTrigger().attr("href"));
                },
                onLoad: function() {
                    setTimeout("configureVoteForm(200, 1000, 150)", 500);
                },
                onClose: function() {
                    $('.contentWrap').empty();
                }
            });
        });
    },

    close: function(){
        $("a[rel='#vote_overlay']").each(function(){
            var ol = $(this).data("overlay");
            if(ol.isOpened()){
                ol.close();
            }
        });
    }
};

function removeSelected() {
    $("a.trig").each(function() {
        if ($(this).parent('td').hasClass('act')) {
            $(this).parent('td').removeClass('act');
        } 
    //        $(this).parent('td').removeClass('act').addClass('inact');
    });
}

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
        hideFlash();
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

function showFlash(msg, tp) {
    if ($('#flash_messages_container').length > 0) {
        $('#flash_messages_container').remove();
    }
    var flashContainer = $("<div id='flash_messages_container' class='flash-messages " +  tp  + " '></div>");
    flashContainer.prepend("<div id='flash_messages_content'>" + msg + "<span class='go-right closeb' id='close_flash'></span></div>");
    $('body').prepend(flashContainer);
    //$('body').animate({'margin-top' : flashContainer.outerHeight()}, 500, function() {});
    $('body').css('margin-top', flashContainer.outerHeight());
    posMenus();
    $('#close_flash').click(function() {
        $('#flash_messages_container').remove();
        //    $('body').animate({'margin-top' : 0}, 500, function(){});
        $('body').css('margin-top', '0');
        posMenus(); //reposition the menus since the structure of the document now changed
    });
//return no;
}

function hideFlash() {
    $('#flash_messages_container').remove();
    //    $('body').animate({'margin-top' : 0}, 500, function(){});
    $('body').css('margin-top', '0');
    posMenus(); //reposition the menus since the structure of the document now changed
}

function prepareToolTip() {
    $('.t-trigger').each(function() {
        $(this).tooltip({
            relative : true,
            position: "bottom left"
        });
    });
}

function posMenus() {
    if ($('#home_nav a').length > 0) {
        var pos = $("#home_nav a").offset();
        var width = $("#home_nav").width();
        var height = $("#home_nav a").outerHeight();
        //show the menu directly over the placeholder

        $("#cat_menu").css( {
            "left": (pos.left) + "px",
            "top":(pos.top + height) + "px"
        });
        $("#city_menu").css( {
            "left": (pos.left) + "px",
            "top":(pos.top + height) + "px"
        });
    }
}
function showMenu() {
    if ($('#city_nav a').hasClass('hover-nav')) {
        $('#city_nav a').removeClass('hover-nav');
        $('#city_menu').toggle('fast');
    }
    $('#cat_nav a').toggleClass('hover-nav');
    $("#cat_menu").toggle('fast');

}
function showCityMenu() {
    if ($('#cat_nav a').hasClass('hover-nav')) {
        $('#cat_nav a').removeClass('hover-nav');
        $('#cat_menu').toggle('fast');
    }
    $('#city_nav a').toggleClass('hover-nav');
    $("#city_menu").toggle('fast');
}

$(document).ready(function() {
    setTimeout(prepareToolTip, 500);

    $(document).bind('ajaxComplete', function() {
        prepareToolTip();
    });

    /** set up the menus **/
    posMenus();
    
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
        showLoading('#com_submit_loading');
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
    $("#city_nav").bind('click', function(){
        showCityMenu();
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
    $('#close_city_menu').click(function(){
        $('#city_nav a').toggleClass('hover-nav');
        $("#city_menu").toggle('fast');
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

    /** for vote form **/
    ModalVoteForm.init();
    /** for the intro prezo **/

    $("a[rel='#intro_prezo']").overlay();
    $('#wrap').html($('#what').html());
    $("a.trig").each(function() {
        $(this).click(function() {
            removeSelected();
            $(this).parent('td').addClass('act')
            var htmlToInsert = $($(this).attr('rel')).html();
            $('#wrap').fadeOut('slow', function() {
                $("#wrap").html(htmlToInsert);
            });
            $('#wrap').fadeIn('slow');
            return false;
        });
    });
//$('#default_trig').trigger('click');
/************** end intro prezo **************/
    
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
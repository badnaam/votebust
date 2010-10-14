function liveLoad(url) {
    $.ajax({
      url: url,
      type: 'GET',
      dataType: 'html',
      beforeSend :function() {
        showLoading("#loading")
      },
      success : function(data){
        $("#content_area").html(data);
      },
      error : function(){},
      complete:function(){
        hideLoading("#loading");
        ModalVoteForm.init();
      }
    });
  }

function hideCommentTools() {
    $("#comment_tools").hide();
    $("#textile-toolbar-comment_body").hide();
    $("#comment_body").css("height", "25px")
}

function showCommentTools() {
    $("#textile-toolbar-comment_body").show();
    $("#comment_tools").show();
    $("#comment_body").css("height", "100px")
    if ($("#comment_body").val() == "Discuss..") {
        $("#comment_body").val('');
    }
}
function incrementCount(id, add) {
    var val = parseInt($(id).text());
    $(id).text(val + add);
}

function doAutoComplete(url){
    $.ajax({
        url: url,
        type : "GET",
        dataType: 'script',
        global : false,
        data : {
            term: $("#vote_topic_header").val()
        }
    });
}
function showEmailOverlay() {
    $('#email_overlay').overlay({
        load : true,
        closeOnClick : false,
        top : '20%',
        left : 'center',
        onBeforeLoad : function() {

        }
    });
    $("#email_overlay").data("overlay").load();

}

function configureEmailOverlay(label, header, email_type, link) {
//    $("#friend_invite_message_message").val(link);
    $('#msg_submit').text(label);
    $('#email_form_header').text(header);
    $('#email_type').val(email_type);
}

function likeComment(cid) {
    commentId = cid.split("_")[1];
    elem = $("#"+ cid);
    if (elem.hasClass("likeme")) {
        meth = "POST";
        url = "/comment_likes";
    } else {
        meth = "DELETE";
        url = "/comment_likes/" + commentId;
    }
    $.ajax({
        url: url,
        type : meth,
        dataType : 'script',
        beforeSend : function() {
            elem.addClass("loading-link");
        },
        complete : function() {
            elem.removeClass("loading-link");
        },
        global : false,
        data : {
            comment_id : commentId
        }
    })
}

function reloadHomeTab() {
    var selected = $( "#home_tabs" ).tabs( "option", "selected" );
    //    $('#home_tabs').tabs('load', selected);
    var selector = "#ui-tabs-" + (selected + 1);
    $(selector).animate({
        opacity: 0
    }, 500, function(){}).animate(
    {
        opacity : 1
    }, 500, function(){}
        );

}

function configureVoteForm(maxVoteTopicHeaderLength, maxVoteTopicLength, maxVoteItemLength) {
    $('.vote-form-more-details').live('click', function() {
        if ($(this).text() == "More Details") {
            $(this).text("Hide Details");
        } else {
            $(this).text("More Details");
        }
        $('.vote-form-details').toggle(50,  function() {
            var pos = $('.vote-form-details').position().top;
            $('.contentWrap').scrollTop(pos);
        });
        //alert($('.vote-form-details').is(':visible'));
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

    $('#vote_submit').live('click', function(){
        $('#vote_topic_form').submit();
        return false;
    });
    
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
        return false;
    });
}

var ModalVoteForm = {
    init: function(){
        $("a[rel='#vote_overlay']").each(function(){
            $(this).overlay({
                closeOnClick: false,
                target: '#vote_overlay',
                fixed: false,
                onBeforeLoad: function() {
                    // grab wrapper element inside content
                    var wrap = this.getOverlay().find(".contentWrap");
                    var self = this;
                    // load the page specified in the trigger
                    wrap.load(this.getTrigger().attr("href"), function() {
                        $('#vote_close', this).live('click', function(){
                            ModalVoteForm.close();
                            //self.close();
                            return false;
                        });
                        $('#edit_vote_close', this).live('click', function(){
                            ModalVoteForm.close();
                            //self.close();
                            return false;
                        });
                    });
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


function showFlashOverlay(msg, tp, err_type) {
    var msg_type = "<div class='big normal-pad l-t-a bld " + tp +  "' id= flash_overlay_type>" + err_type + "</div>";
    $('#flash_overlay_type').remove();
    $('#flash_overlay').prepend(msg_type);
    $("#flash_overlay_message").text(msg);
    $('#flash_overlay').overlay({
        load : true,
        close : '#close_flash_overlay',
        closeOnClick : false,
        top : '30%',
        left : 'center'

    });
    $("#flash_overlay").data("overlay").load();
}
function showFlash(msg, tp) {
    if ($('#flash_messages_container').length > 0) {
        //$('#flash_messages_container').remove();
        flashAnimatedHide();
    }

    var flashContainer = $("<div id='flash_messages_container' class='flash-messages " +  tp  + " '></div>");
    flashContainer.prepend("<div id='flash_messages_content'>" + msg + "<span class='go-right closeb' id='close_flash'></span></div>");
    $('body').prepend(flashContainer);
    flashContainer.animate({
        opacity : .1
    }, '500', function(){
        flashContainer.css('opacity', 1)
    })
    //$('body').animate({'margin-top' : flashContainer.outerHeight()}, 500, function() {});
    $('body').css('margin-top', flashContainer.outerHeight());
    posMenus();
    $('#close_flash').click(function() {
        //$('#flash_messages_container').remove();
        flashAnimatedHide();
        //    $('body').animate({'margin-top' : 0}, 500, function(){});
        $('body').css('margin-top', '0');
        posMenus(); //reposition the menus since the structure of the document now changed
    });
//return no;
}

function flashAnimatedHide() {
    /**$('#flash_messages_container').animate({
         opacity : 0
    }, 'slow', function(){});**/
    $('#flash_messages_container').remove();
}
function hideFlash() {
    flashAnimatedHide();
    //    $('body').animate({'margin-top' : 0}, 500, function(){});
    $('body').css('margin-top', '0');
    posMenus(); //reposition the menus since the structure of the document now changed
}

function prepareToolTip() {
    $('.t-trigger').each(function() {
        $(this).tooltip({
            relative : true,
            position: "top center",
            cancelDefault : true
        });
    });
}

function posMenus() {
    if ($('.header').length > 0 && $('.header_links').length > 0) {
        //var selector = "#home_nav a";
        var selector = ".header";
        var headerSelector = ".header"
        var selectorHeaderLinks = ".header_links"

        var pos = $(selector).offset();
        var width = $(headerSelector).width();
        var height = $(selector).outerHeight();
        //show the menu directly over the placeholder

        $("#cat_menu").css( {
            "left": (pos.left) + "px",
            "top":(pos.top +   height) + "px"
        });
        $(".user-links").css( {
            "left": ($(selectorHeaderLinks).offset().left) + "px",
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
    $('#comment_submit').click(function() {
        if ($("#comment_body").val().length > 0) {
            $('#new_comment').submit();
        }
        return false;
    });

    $('#new_comment').submit(function (){
        showLoading('#com_submit_loading');
        $.post($(this).attr('action'), $(this).serialize(), function(data) {
            hideLoading('#com_submit_loading');
            hideCommentTools();
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
                global:true,
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
    /* Theme switcher*/
    //     $('#switcher').themeswitcher();

    /** for the intro prezo **/

    $("a[rel='#intro_prezo']").overlay({
        top: "center"
    });
    /**$('#wrap').html($('#what').html());
    $("a.trig").each(function() {
        $(this).mouseover(function() {
            removeSelected();
            $(this).parent('td').addClass('act')
            var htmlToInsert = $($(this).attr('rel')).html();
            var options = null
            $('#wrap').toggle('drop', options, 500, function() {
                $("#wrap").html(htmlToInsert);
            });
            $('#wrap').toggle('drop', options, 500);
            return false;
        });
    });**/

    if ($.cookie('show_voteable_intro') == '1') {
        $("a[rel='#intro_prezo']").click();
        $.cookie('show_voteable_intro', '0')
    }
    setInterval(reloadHomeTab, 10000);

    if ($('#msg_submit').length > 0) {
        $("#msg_submit").click(function() {
            var et = $("#email_type").val();
            if (et == "vote" || et == "profile") {
                $("#friend_invite_message_shared_url").val(document.location.href);
            }
            $("#email_form").submit();
        })
    }
    if ($('#overlay_close').length > 0) {
        $("#overlay_close").click(function() {
            //$("#email_overlay").data("overlay").close();
            $(this).parents(".generic-overlay").data("overlay").close();
            return false;
        })
    }
/************** end intro prezo **************/
    $("#profile_link").click(function() {
        $(".user-links").toggle();
    })
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
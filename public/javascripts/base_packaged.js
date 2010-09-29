(function(f){function p(a,b,c){var h=c.relative?a.position().top:a.offset().top,e=c.relative?a.position().left:a.offset().left,i=c.position[0];h-=b.outerHeight()-c.offset[0];e+=a.outerWidth()+c.offset[1];var j=b.outerHeight()+a.outerHeight();if(i=="center")h+=j/2;if(i=="bottom")h+=j;i=c.position[1];a=b.outerWidth()+a.outerWidth();if(i=="center")e-=a/2;if(i=="left")e-=a;return{top:h,left:e}}function u(a,b){var c=this,h=a.add(c),e,i=0,j=0,m=a.attr("title"),q=a.attr("data-tooltip"),r=n[b.effect],l,s=a.is(":input"),v=s&&a.is(":checkbox, :radio, select, :button, :submit"),t=a.attr("type"),k=b.events[t]||b.events[s?v?"widget":"input":"def"];if(!r)throw'Nonexistent effect "'+b.effect+'"';k=k.split(/,\s*/);if(k.length!=2)throw"Tooltip: bad events configuration for "+t;a.bind(k[0],function(d){clearTimeout(i);if(b.predelay)j=setTimeout(function(){c.show(d)},b.predelay);else c.show(d)}).bind(k[1],function(d){clearTimeout(j);if(b.delay)i=setTimeout(function(){c.hide(d)},b.delay);else c.hide(d)});if(m&&b.cancelDefault){a.removeAttr("title");a.data("title",m)}f.extend(c,{show:function(d){if(!e){if(q)e=f(q);else if(m)e=f(b.layout).addClass(b.tipClass).appendTo(document.body).hide().append(m);else if(b.tip)e=f(b.tip).eq(0);else{e=a.next();e.length||(e=a.parent().next())}if(!e.length)throw"Cannot find tooltip for "+a;}if(c.isShown())return c;e.stop(true,true);var g=p(a,e,b);d=d||f.Event();d.type="onBeforeShow";h.trigger(d,[g]);if(d.isDefaultPrevented())return c;g=p(a,e,b);e.css({position:"absolute",top:g.top,left:g.left});l=true;r[0].call(c,function(){d.type="onShow";l="full";h.trigger(d)});g=b.events.tooltip.split(/,\s*/);e.bind(g[0],function(){clearTimeout(i);clearTimeout(j)});g[1]&&!a.is("input:not(:checkbox, :radio), textarea")&&e.bind(g[1],function(o){o.relatedTarget!=a[0]&&a.trigger(k[1].split(" ")[0])});return c},hide:function(d){if(!e||!c.isShown())return c;d=d||f.Event();d.type="onBeforeHide";h.trigger(d);if(!d.isDefaultPrevented()){l=false;n[b.effect][1].call(c,function(){d.type="onHide";h.trigger(d)});return c}},isShown:function(d){return d?l=="full":l},getConf:function(){return b},getTip:function(){return e},getTrigger:function(){return a}});f.each("onHide,onBeforeShow,onShow,onBeforeHide".split(","),function(d,g){f.isFunction(b[g])&&f(c).bind(g,b[g]);c[g]=function(o){f(c).bind(g,o);return c}})}f.tools=f.tools||{version:"1.2.4"};f.tools.tooltip={conf:{effect:"toggle",fadeOutSpeed:"fast",predelay:0,delay:30,opacity:1,tip:0,position:["top","center"],offset:[0,0],relative:false,cancelDefault:true,events:{def:"mouseenter,mouseleave",input:"focus,blur",widget:"focus mouseenter,blur mouseleave",tooltip:"mouseenter,mouseleave"},layout:"<div/>",tipClass:"tooltip"},addEffect:function(a,b,c){n[a]=[b,c]}};var n={toggle:[function(a){var b=this.getConf(),c=this.getTip();b=b.opacity;b<1&&c.css({opacity:b});c.show();a.call()},function(a){this.getTip().hide();a.call()}],fade:[function(a){var b=this.getConf();this.getTip().fadeTo(b.fadeInSpeed,b.opacity,a)},function(a){this.getTip().fadeOut(this.getConf().fadeOutSpeed,a)}]};f.fn.tooltip=function(a){var b=this.data("tooltip");if(b)return b;a=f.extend(true,{},f.tools.tooltip.conf,a);if(typeof a.position=="string")a.position=a.position.split(/,?\s/);this.each(function(){b=new u(f(this),a);f(this).data("tooltip",b)});return a.api?b:this}})(jQuery);(function(e){function n(f,c){var a=e(c);return a.length<2?a:f.parent().find(c)}function t(f,c){var a=this,l=f.add(a),g=f.children(),k=0,m=c.vertical;j||(j=a);if(g.length>1)g=e(c.items,f);e.extend(a,{getConf:function(){return c},getIndex:function(){return k},getSize:function(){return a.getItems().size()},getNaviButtons:function(){return o.add(p)},getRoot:function(){return f},getItemWrap:function(){return g},getItems:function(){return g.children(c.item).not("."+c.clonedClass)},move:function(b,d){return a.seekTo(k+
b,d)},next:function(b){return a.move(1,b)},prev:function(b){return a.move(-1,b)},begin:function(b){return a.seekTo(0,b)},end:function(b){return a.seekTo(a.getSize()-1,b)},focus:function(){return j=a},addItem:function(b){b=e(b);if(c.circular){g.children("."+c.clonedClass+":last").before(b);g.children("."+c.clonedClass+":first").replaceWith(b.clone().addClass(c.clonedClass))}else g.append(b);l.trigger("onAddItem",[b]);return a},seekTo:function(b,d,h){b.jquery||(b*=1);if(c.circular&&b===0&&k==-1&&d!==0)return a;if(!c.circular&&b<0||b>a.getSize()||b<-1)return a;var i=b;if(b.jquery)b=a.getItems().index(b);else i=a.getItems().eq(b);var q=e.Event("onBeforeSeek");if(!h){l.trigger(q,[b,d]);if(q.isDefaultPrevented()||!i.length)return a}i=m?{top:-i.position().top}:{left:-i.position().left};k=b;j=a;if(d===undefined)d=c.speed;g.animate(i,d,c.easing,h||function(){l.trigger("onSeek",[b])});return a}});e.each(["onBeforeSeek","onSeek","onAddItem"],function(b,d){e.isFunction(c[d])&&e(a).bind(d,c[d]);a[d]=function(h){e(a).bind(d,h);return a}});if(c.circular){var r=a.getItems().slice(-1).clone().prependTo(g),s=a.getItems().eq(1).clone().appendTo(g);r.add(s).addClass(c.clonedClass);a.onBeforeSeek(function(b,d,h){if(!b.isDefaultPrevented())if(d==-1){a.seekTo(r,h,function(){a.end(0)});return b.preventDefault()}else d==a.getSize()&&a.seekTo(s,h,function(){a.begin(0)})});a.seekTo(0,0,function(){})}var o=n(f,c.prev).click(function(){a.prev()}),p=n(f,c.next).click(function(){a.next()});!c.circular&&a.getSize()>1&&a.onBeforeSeek(function(b,d){setTimeout(function(){if(!b.isDefaultPrevented()){o.toggleClass(c.disabledClass,d<=0);p.toggleClass(c.disabledClass,d>=a.getSize()-1)}},1)});c.mousewheel&&e.fn.mousewheel&&f.mousewheel(function(b,d){if(c.mousewheel){a.move(d<0?1:-1,c.wheelSpeed||50);return false}});c.keyboard&&e(document).bind("keydown.scrollable",function(b){if(!(!c.keyboard||b.altKey||b.ctrlKey||e(b.target).is(":input")))if(!(c.keyboard!="static"&&j!=a)){var d=b.keyCode;if(m&&(d==38||d==40)){a.move(d==38?-1:1);return b.preventDefault()}if(!m&&(d==37||d==39)){a.move(d==37?-1:1);return b.preventDefault()}}});c.initialIndex&&a.seekTo(c.initialIndex,0,function(){})}e.tools=e.tools||{version:"1.2.4"};e.tools.scrollable={conf:{activeClass:"active",circular:false,clonedClass:"cloned",disabledClass:"disabled",easing:"swing",initialIndex:0,item:null,items:".items",keyboard:true,mousewheel:false,next:".next",prev:".prev",speed:400,vertical:false,wheelSpeed:0}};var j;e.fn.scrollable=function(f){var c=this.data("scrollable");if(c)return c;f=e.extend({},e.tools.scrollable.conf,f);this.each(function(){c=new t(e(this),f);e(this).data("scrollable",c)});return f.api?c:this}})(jQuery);(function(c){var g=c.tools.scrollable;g.autoscroll={conf:{autoplay:true,interval:3E3,autopause:true}};c.fn.autoscroll=function(d){if(typeof d=="number")d={interval:d};var b=c.extend({},g.autoscroll.conf,d),h;this.each(function(){var a=c(this).data("scrollable");if(a)h=a;var e,i,f=true;a.play=function(){if(!e){f=false;e=setInterval(function(){a.next()},b.interval);a.next()}};a.pause=function(){e=clearInterval(e)};a.stop=function(){a.pause();f=true};b.autopause&&a.getRoot().add(a.getNaviButtons()).hover(function(){a.pause();clearInterval(i)},function(){f||(i=setTimeout(a.play,b.interval))});b.autoplay&&setTimeout(a.play,b.interval)});return b.api?h:this}})(jQuery);(function(d){function p(b,g){var h=d(g);return h.length<2?h:b.parent().find(g)}var m=d.tools.scrollable;m.navigator={conf:{navi:".navi",naviItem:null,activeClass:"active",indexed:false,idPrefix:null,history:false}};d.fn.navigator=function(b){if(typeof b=="string")b={navi:b};b=d.extend({},m.navigator.conf,b);var g;this.each(function(){function h(a,c,i){e.seekTo(c);if(j){if(location.hash)location.hash=a.attr("href").replace("#","")}else return i.preventDefault()}function f(){return k.find(b.naviItem||"> *")}function n(a){var c=d("<"+(b.naviItem||"a")+"/>").click(function(i){h(d(this),a,i)}).attr("href","#"+a);a===0&&c.addClass(l);b.indexed&&c.text(a+1);b.idPrefix&&c.attr("id",b.idPrefix+a);return c.appendTo(k)}function o(a,c){a=f().eq(c.replace("#",""));a.length||(a=f().filter("[href="+c+"]"));a.click()}var e=d(this).data("scrollable"),k=b.navi.jquery?b.navi:p(e.getRoot(),b.navi),q=e.getNaviButtons(),l=b.activeClass,j=b.history&&d.fn.history;if(e)g=e;e.getNaviButtons=function(){return q.add(k)};f().length?f().each(function(a){d(this).click(function(c){h(d(this),a,c)})}):d.each(e.getItems(),function(a){n(a)});e.onBeforeSeek(function(a,c){setTimeout(function(){if(!a.isDefaultPrevented()){var i=f().eq(c);!a.isDefaultPrevented()&&i.length&&f().removeClass(l).eq(c).addClass(l)}},1)});e.onAddItem(function(a,c){c=n(e.getItems().index(c));j&&c.history(o)});j&&f().history(o)});return b.api?g:this}})(jQuery);(function(a){function t(d,b){var c=this,i=d.add(c),o=a(window),k,f,m,g=a.tools.expose&&(b.mask||b.expose),n=Math.random().toString().slice(10);if(g){if(typeof g=="string")g={color:g};g.closeOnClick=g.closeOnEsc=false}var p=b.target||d.attr("rel");f=p?a(p):d;if(!f.length)throw"Could not find Overlay: "+p;d&&d.index(f)==-1&&d.click(function(e){c.load(e);return e.preventDefault()});a.extend(c,{load:function(e){if(c.isOpened())return c;var h=q[b.effect];if(!h)throw'Overlay: cannot find effect : "'+b.effect+'"';b.oneInstance&&a.each(s,function(){this.close(e)});e=e||a.Event();e.type="onBeforeLoad";i.trigger(e);if(e.isDefaultPrevented())return c;m=true;g&&a(f).expose(g);var j=b.top,r=b.left,u=f.outerWidth({margin:true}),v=f.outerHeight({margin:true});if(typeof j=="string")j=j=="center"?Math.max((o.height()-v)/2,0):parseInt(j,10)/100*o.height();if(r=="center")r=Math.max((o.width()-u)/2,0);h[0].call(c,{top:j,left:r},function(){if(m){e.type="onLoad";i.trigger(e)}});g&&b.closeOnClick&&a.mask.getMask().one("click",c.close);b.closeOnClick&&a(document).bind("click."+n,function(l){a(l.target).parents(f).length||c.close(l)});b.closeOnEsc&&a(document).bind("keydown."+n,function(l){l.keyCode==27&&c.close(l)});return c},close:function(e){if(!c.isOpened())return c;e=e||a.Event();e.type="onBeforeClose";i.trigger(e);if(!e.isDefaultPrevented()){m=false;q[b.effect][1].call(c,function(){e.type="onClose";i.trigger(e)});a(document).unbind("click."+n).unbind("keydown."+n);g&&a.mask.close();return c}},getOverlay:function(){return f},getTrigger:function(){return d},getClosers:function(){return k},isOpened:function(){return m},getConf:function(){return b}});a.each("onBeforeLoad,onStart,onLoad,onBeforeClose,onClose".split(","),function(e,h){a.isFunction(b[h])&&a(c).bind(h,b[h]);c[h]=function(j){a(c).bind(h,j);return c}});k=f.find(b.close||".close");if(!k.length&&!b.close){k=a('<a class="close"></a>');f.prepend(k)}k.click(function(e){c.close(e)});b.load&&c.load()}a.tools=a.tools||{version:"1.2.4"};a.tools.overlay={addEffect:function(d,b,c){q[d]=[b,c]},conf:{close:null,closeOnClick:true,closeOnEsc:true,closeSpeed:"fast",effect:"default",fixed:!a.browser.msie||a.browser.version>6,left:"center",load:false,mask:null,oneInstance:true,speed:"normal",target:null,top:"10%"}};var s=[],q={};a.tools.overlay.addEffect("default",function(d,b){var c=this.getConf(),i=a(window);if(!c.fixed){d.top+=i.scrollTop();d.left+=i.scrollLeft()}d.position=c.fixed?"fixed":"absolute";this.getOverlay().css(d).fadeIn(c.speed,b)},function(d){this.getOverlay().fadeOut(this.getConf().closeSpeed,d)});a.fn.overlay=function(d){var b=this.data("overlay");if(b)return b;if(a.isFunction(d))d={onBeforeLoad:d};d=a.extend(true,{},a.tools.overlay.conf,d);this.each(function(){b=new t(a(this),d);s.push(b);a(this).data("overlay",b)});return d.api?b:this}})(jQuery);function configureVoteForm(maxVoteTopicHeaderLength,maxVoteTopicLength,maxVoteItemLength){$('.vote-form-more-details').live('click',function(){$('.vote-form-details').toggle('');return false;});$('#vote_topic_header').keyup(function(){update_chars_left(maxVoteTopicHeaderLength,$('#vote_topic_header')[0],$('#vote_topic_header').next('p'));});$('#vote_topic_topic').keyup(function(){update_chars_left(maxVoteTopicLength,$('#vote_topic_topic')[0],$('#vote_topic_topic').next('p'));});$("input[id^='vote_topic_vote_items_attributes']").each(function(){$(this).keyup(function(){update_chars_left(maxVoteItemLength,$(this)[0],$(this).next('p'));})});$('#vote_submit').button({icons:{primary:'ui-icon-circle-check'}}).click(function(){$('#vote_topic_form').submit();return false;});$('#vote_topic_form').submit(function(){$.ajax({type:'POST',dataType:'script',url:$(this).attr('action'),data:$(this).serialize(),global:false,beforeSend:function(){showLoading("#form_loading")},complete:function(){hideLoading("#form_loading")}});return false;});}
var ModalVoteForm={init:function(){$("a[rel='#vote_overlay']").each(function(){$(this).overlay({closeOnClick:false,target:'#vote_overlay',fixed:false,onBeforeLoad:function(){var wrap=this.getOverlay().find(".contentWrap");wrap.load(this.getTrigger().attr("href"));},onLoad:function(){setTimeout("configureVoteForm(200, 1000, 150)",500);},onClose:function(){$('.contentWrap').empty();}});});},close:function(){$("a[rel='#vote_overlay']").each(function(){var ol=$(this).data("overlay");if(ol.isOpened()){ol.close();}});}};function removeSelected(){$("a.trig").each(function(){if($(this).parent('td').hasClass('act')){$(this).parent('td').removeClass('act');}});}
function handleCommentText(maxLength){$('#comment_body').keyup(function(){update_chars_left(maxLength,$('#comment_body')[0],$('#limit_status'));});}
function showProgress(elem){$(elem).show();}
function hideProgress(elem){$(elem).hide();}
function showLoading(elem){$(elem).show();$(elem).parent('div').animate({opacity:0.3},'slow',function(){});}
function hideLoading(elem){$(elem).hide();$(elem).parent('div').animate({opacity:1.0},'slow',function(){});}
function update_chars_left(max_len,target_input,display_element){var text_len=target_input.value.length;if(text_len>=max_len){target_input.value=target_input.value.substring(0,max_len);display_element.html("0 characters left");}else{display_element.html((max_len-text_len)+" characters left");}}
function setVotingCounter(inter){var resetVoteCount=setInterval(function(){$('#vote_count').val(0);hideFlash();},inter);}
function handleVoting(id){var sel_list=$("li:has(a.cancel)",'#vote_items_list_voted');if(sel_list.length==0){$("li[id^='v-item-']","#vote_items_list_voted").each(function(){anchor=$(this).children('a');if(anchor.attr('id')!=id){txt=anchor.text();anchor.remove();$(this).text(txt);}else{anchor.removeClass('vote').addClass('cancel');anchor.children('span').removeClass('ui-icon-check').addClass('ui-icon-close');}});}else{var selected_id=sel_list.children('a').attr('id');var txt=sel_list.text();if(selected_id!=id){sel_list.empty().text(txt);var new_selection=$('#v-item-'+id);var new_text=new_selection.text();new_selection.empty().append(makeCancelElement(id,new_text));}}
$('#vote_items_list_voted').show('slow');$('#vote_items_list_unvoted').hide('slow');}
function makeCancelElement(id,txt){var cancel_link=$("<a></a>").attr('class','cancel take-action').attr('id',id).attr('href','#');var cancel_button=$('<span></span>').attr('class','ui-icon ui-icon-close vote-icon');var cancel_element=cancel_link.append(cancel_button).append(txt);return cancel_element;}
function showFlash(msg,tp){if($('#flash_messages_container').length>0){flashAnimatedHide();}
var flashContainer=$("<div id='flash_messages_container' class='flash-messages "+tp+" '></div>");flashContainer.prepend("<div id='flash_messages_content'>"+msg+"<span class='go-right closeb' id='close_flash'></span></div>");$('body').prepend(flashContainer);flashContainer.animate({opacity:.1},'500',function(){flashContainer.css('opacity',1)})
$('body').css('margin-top',flashContainer.outerHeight());posMenus();$('#close_flash').click(function(){flashAnimatedHide();$('body').css('margin-top','0');posMenus();});}
function flashAnimatedHide(){$('#flash_messages_container').remove();}
function hideFlash(){flashAnimatedHide();$('body').css('margin-top','0');posMenus();}
function prepareToolTip(){$('.t-trigger').each(function(){$(this).tooltip({relative:true,position:"bottom left"});});}
function posMenus(){if($('#home_nav a').length>0){var pos=$("#home_nav a").offset();var width=$("#home_nav").width();var height=$("#home_nav a").outerHeight();$("#cat_menu").css({"left":(pos.left)+"px","top":(pos.top+height)+"px"});$("#city_menu").css({"left":(pos.left)+"px","top":(pos.top+height)+"px"});}}
function showMenu(){if($('#city_nav a').hasClass('hover-nav')){$('#city_nav a').removeClass('hover-nav');$('#city_menu').toggle('fast');}
$('#cat_nav a').toggleClass('hover-nav');$("#cat_menu").toggle('fast');}
function showCityMenu(){if($('#cat_nav a').hasClass('hover-nav')){$('#cat_nav a').removeClass('hover-nav');$('#cat_menu').toggle('fast');}
$('#city_nav a').toggleClass('hover-nav');$("#city_menu").toggle('fast');}
$(document).ready(function(){setTimeout(prepareToolTip,500);$(document).bind('ajaxComplete',function(){prepareToolTip();});posMenus();$('#comment_submit').button({icons:{primary:'ui-icon-comment'}}).click(function(){$('#new_comment').submit();return false;});$('#new_comment').submit(function(){showLoading('#com_submit_loading');$.post($(this).attr('action'),$(this).serialize(),function(data){hideLoading('#com_submit_loading');},"script");return false;});$('#new_vote_btn').button({icons:{primary:'ui-icon-lightbulb'}});$('#search_term').focus(function(){$(this).val('');});$("#search_form a").click(function(){$(this).parents().filter("form").trigger("submit");});$('#search_button').button({icons:{primary:'ui-icon-search'},text:false});$("#cat_nav").bind('click',function(){showMenu();return false;});$("#city_nav").bind('click',function(){showCityMenu();return false;});if($('.load-widget-link').length>0){$('.load-widget-link').each(function(){$.ajax({type:'GET',url:$(this).attr('href'),dataType:'script',global:false,context:$(this),success:function(){$(this).parent('div').slideDown('slow',function(){});}});});}
$('#close_cat_menu').click(function(){$('#cat_nav a').toggleClass('hover-nav');$("#cat_menu").toggle('fast');});$('#close_city_menu').click(function(){$('#city_nav a').toggleClass('hover-nav');$("#city_menu").toggle('fast');});$('#search_term').focus(function(){$(this).val('');});$("#search_form a").click(function(){$(this).parents().filter("form").trigger("submit");});$('#search_button').button({icons:{primary:'ui-icon-search'},text:false});ModalVoteForm.init();$("a[rel='#intro_prezo']").overlay();$('#wrap').html($('#what').html());$("a.trig").each(function(){$(this).click(function(){removeSelected();$(this).parent('td').addClass('act')
var htmlToInsert=$($(this).attr('rel')).html();$('#wrap').fadeOut('slow',function(){$("#wrap").html(htmlToInsert);});$('#wrap').fadeIn('slow');return false;});});});jQuery.cookie=function(key,value,options){if(arguments.length>1&&(value===null||typeof value!=="object")){options=jQuery.extend({},options);if(value===null){options.expires=-1;}
if(typeof options.expires==='number'){var days=options.expires,t=options.expires=new Date();t.setDate(t.getDate()+days);}
return(document.cookie=[encodeURIComponent(key),'=',options.raw?String(value):encodeURIComponent(String(value)),options.expires?'; expires='+options.expires.toUTCString():'',options.path?'; path='+options.path:'',options.domain?'; domain='+options.domain:'',options.secure?'; secure':''].join(''));}
options=value||{};var result,decode=options.raw?function(s){return s;}:decodeURIComponent;return(result=new RegExp('(?:^|; )'+encodeURIComponent(key)+'=([^;]*)').exec(document.cookie))?decode(result[1]):null;};
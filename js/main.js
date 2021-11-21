// I'd like to use console.logs, for modern browsers. This should stop this being an issue for IE.
if(!window.console){console={log: function(){}}}

$('html').removeClass('no-js').addClass('js');

// Hides the tooltips, if the user clicks outside of them.
$(document).on('click', function(e) {
	if (!$(e.target).closest('.js-tooltip').length) {
		$('.toggle').prop('checked', false);
	}
});

// Adds a close button inside two kinds of tooltip bubble
$('sup .details, .tags .details').prepend('<button title="Close">&#215;</button>');

// Closes the current speech bubble
$('.js-tooltip button').on('click', function() {
	$(this).closest('.js-tooltip').find('.toggle').prop('checked', false);
});

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
| Toggle any hashlink with a class of toggle-link. Assumes that there's a jump link             |
| relationship between link and target. Markup structure and nesting is not important.          |
|                                                                                               |
| Example markup:                                                                               |
| <p><a href="#my-target" data-open="Open" data-close="Close" class="toggle-link">Open</a></p>  |
| <p id="my-target" class="js-hide">More information here</p>                                   |
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
$('.toggle-link').click(function (e) {
	togLink = $(this);
	// Has the rel been used correctly?
	if (togLink.attr('href').indexOf('#') != -1) {
		target = $(togLink.attr('href').substring(togLink.attr('href').indexOf("#")));
		openTxt = togLink.attr('data-open');
		closeTxt = togLink.attr('data-close');
		// Does the target exist, and is it currently hidden?
		if (target.length && target.is(':hidden')) {
			target.slideDown('400', function() {
				target.addClass('open');
			});
			if (closeTxt != '') togLink.html(closeTxt);
			togLink.addClass('open');
		}
		else if (target.length) {
			target.removeClass('open');
			target.slideUp('400', function(){});
			if (openTxt != '') togLink.html(openTxt);
			togLink.removeClass('open');
		}
		return false;
	}
});

// This loads the Disqus comments, but only when the user clicks on the
// "Show comments (Disqus)" link, for performance and paranoia reasons.
$('.js-disqus').one('click', function() {
	var disqus_config = function () {
		this.page.url = pageUrl;
		this.page.identifier = padeID;
	};
	(function() {  // DON'T EDIT BELOW THIS LINE
		var d = document, s = d.createElement('script');

		s.src = '//dearcharlotte.disqus.com/embed.js';

		s.setAttribute('data-timestamp', +new Date());
		(d.head || d.body).appendChild(s);
	})();
});


/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
| This decides if a single <note/> speech bubble should be alligned to the left |
| or the right of the (❆). It's called if the user either clicks on a (❆) or    |
| resizes the browser.                                                          |
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
function alignSpeech($sup) {
	var winWidth = $(window).width();
	var tipOff = $sup.offset();

	// Cleanup: the user might trigger a tooltip, then resize the browser.
	$sup.removeClass('tip-left tip-right');

	// Is the (❆) too close to the left-hand edge of the screen?
	if (tipOff.left < 100) {
		$sup.addClass('tip-left');
	}

	// Is the (❆) too close to the right-hand edge of the screen?
	else if ((winWidth - tipOff.left) < 100) {
		$sup.addClass('tip-right');
	}
}
// When the user resizes the browser, any <note/> speech bubbles which move might need
// to be alligned differently. This also needs to happen on load, to stop horizontal
// scrolling.
$(window).on('load resize',function(){
	$($('.js-tooltip')).each(function() {
		alignSpeech($(this));
	});
});

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
| Because of the parse order of client-side XSLT, *some* browsers (I'm looking  |
| at *you*, Firefox) won't honour jump links on page load. Also, external       |
| resources cause the page to jump about a bit, even in browsers where jump     |
| links *do* work, so let's wait until the page fully loads, then scroll.       |
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
$(window).load(function() {
	if(location.hash != '') {
		$('html, body').animate({
			scrollTop: $(location.hash).offset().top
		}, 1000);
	}
});

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *\
| Evil tracking                                                                 |
| I'm curious: is anyone actually using those tags I spent so long populating   |
| with content, or do they just work as a sort of amusing summary of the        |
| current episode?                                                              |
| In this post-GDPR world, my curiosity has all but evaporated.                 |
\* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
/*$('[aria-label] label').on('click', function() {
    var eventCategory = $(this).closest('[aria-label]').attr('aria-label');
    var eventLabel = $(this).text();
    ga('send', 'event', eventCategory, 'click', eventLabel);
});

// As above, but for the <note/>s
$('sup label').on('click', function() {
	var checkID = $(this).attr('for');
    var eventLabel = $('#'+ checkID).next().text();
    var eventValue = checkID.substr(4);
	if (eventLabel !== '' && eventValue !== '') {
		ga('send', 'event', 'Note', 'click', eventLabel, eventValue);
	} else {
		console.log('Note tracking failed.');
	}
});

// As above, but for the kind of people who want to see the comments (weirdos)
$('.comments .toggle-link').on('click', function() {
    var eventLabel;
	if ($(this).text() === 'Hide comments') {
		eventLabel = 'Comments shown';
	} else {
		eventLabel = 'Comments hidden';
	}
	ga('send', 'event', 'Comments', 'click', eventLabel);
});

// If an event happens, but not on the live site
if(location.hostname.match('dear-charlotte') === null){
	function ga() {
		for (var i = 0, j = arguments.length; i < j; i++) console.log(arguments[i]);
	}
}*/

// End evil tracking

// Something lighter: can I get a cat to creep her way round the side of the page?
$(window).on('resize scroll',function(){
	$('.purhundi').each(function(index) {
		var catHeight = parseInt($(this)[0].getBoundingClientRect().height);
		/* Long story. So even though I'm serving the client-side XSLT with the correct
		Doctype, Chrome is running in BackCompat mode. This means that the standards
		compliant method of getting the viewport height returns the whole document
		height instead. However, there is an older way... */
		var viewHeight;
		if (document.compatMode === 'BackCompat') {
			viewHeight = document.body.clientHeight;
		} else if (document.compatMode === 'CSS1Compat') {
			viewHeight = document.documentElement.clientHeight;
		} else {
			viewHeight = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
		}
		// This will return true as soon as the bottom of the cat crosses the bottom of the page
		if($(this)[0].getBoundingClientRect().top < (viewHeight)) {
			$('.purhundi').eq(index).addClass('pop');
		}
	});

});

// Shoo!
$('.purhundi').on('click', function() {
	$(this).removeClass('pop');
});

require('../css/app.scss');

var jQuery = require('jquery');
require('bootstrap');
var hljs = require('highlight.js');

hljs.initHighlightingOnLoad();

(function($){
    $(function(){
        $(".twitter-tweet").each(function(){
            var $this = $(this);
            twttr.widgets.createTweet(
                $this.data("tweet-id"),
                $this.get(0)
            );
        });
    });
}(jQuery));

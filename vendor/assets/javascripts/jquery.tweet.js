// Based on http://github.com/seaofclouds/tweet/

(function($) {

  $.fn.tweet = function(o){
    var s = {
      username: ["rubygems_status"],          // [string]   required, unless you want to display our tweets. :) it can be an array, just do ["username1","username2","etc"]
      count: 8,                               // [integer]  how many tweets to display?
      loading_text: null                     // [string]   optional loading text, displayed while tweets load
    }

    if(o) $.extend(s, o);

    $.fn.extend({
      linkUrl: function() {
        var returning = [];
        var regexp = /((ftp|http|https):\/\/(\w+:{0,1}\w*@)?(\S+)(:[0-9]+)?(\/|\/([\w#!:.?+=&%@!\-\/]))?)/gi;
        this.each(function() {
          returning.push(this.replace(regexp,"<a href=\"$1\">$1</a>"))
        });
        return $(returning);
      },
      linkUser: function() {
        var returning = [];
        var regexp = /[\@]+([A-Za-z0-9-_]+)/gi;
        this.each(function() {
          returning.push(this.replace(regexp,"<a href=\"http://twitter.com/$1\">@$1</a>"))
        });
        return $(returning);
      },
      linkHash: function() {
        var returning = [];
        var regexp = / [\#]+([A-Za-z0-9-_]+)/gi;
        this.each(function() {
          returning.push(this.replace(regexp, ' <a href="https://search.twitter.com/search?q=&tag=$1&lang=all&from='+s.username.join("%2BOR%2B")+'">#$1</a>'))
        });
        return $(returning);
      }
    });

    function relative_time(time_value) {
      var parsed_date = Date.parse(time_value);
      var relative_to = (arguments.length > 1) ? arguments[1] : new Date();
      var delta = parseInt((relative_to.getTime() - parsed_date) / 1000);
      if(delta < 60) {
      return 'less than a minute ago';
      } else if(delta < 120) {
      return 'about a minute ago';
      } else if(delta < (45*60)) {
      return (parseInt(delta / 60)).toString() + ' minutes ago';
      } else if(delta < (90*60)) {
      return 'about an hour ago';
      } else if(delta < (24*60*60)) {
      return 'about ' + (parseInt(delta / 3600)).toString() + ' hours ago';
      } else if(delta < (48*60*60)) {
      return '1 day ago';
      } else {
      return (parseInt(delta / 86400)).toString() + ' days ago';
      }
    }

    return this.each(function(){
      var list = $(this);
      var loading = $('<p class="loading">'+s.loading_text+'</p>');
      if(typeof(s.username) == "string"){
        s.username = [s.username];
      }
      var query = '';
      if(s.query) {
        query += 'q='+s.query;
      }
      query += '&q=from:'+s.username.join('%20OR%20from:');
      var url = 'https://search.twitter.com/search.json?&'+query+'&rpp=20&callback=?';
      if (s.loading_text) $(this).append(loading);
      $.getJSON(url, function(data){
        if (s.loading_text) loading.remove();
        var itemsShown = 0;
        $.each(data.results, function(i,item){
          if (itemsShown >= s.count) return

          if (item.text.match(/^(@([A-Za-z0-9-_]+)) .*/i)) { // reply (don't show)
            return
          } else if (item.text.match(/^RT (@([A-Za-z0-9-_]+)).*/i)) { // retweets (don't show)
            return
          }

          var join = ((s.join_text) ? join_template : ' ')
          var date = '<p class="meta"><a href="http://twitter.com/'+item.from_user+'/statuses/'+item.id+'" title="view tweet on twitter">'+relative_time(item.created_at)+'</a></p>';
          var text = '<p>' +$([item.text]).linkUrl().linkUser().linkHash()[0]+ '</p>';

          // until we create a template option, arrange the items below to alter a tweet's display.
          list.append('<div class="tweet">' + text + date + '</div>');

          itemsShown++;
        });
      });

    });
  };
})(jQuery);
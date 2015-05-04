<%@ page language="java" import="java.util.*" pageEncoding="ISO-8859-1"%>
<%@ page import="org.music.analysis.module.*"%>
<%
	Song song = new Song();
	song = (Song) request.getAttribute("obj_song");
	String urlKey = song.getId();
	String sName = song.getName();
	String sGenre = song.getGenre();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>Insert title here</title>
	<script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
	<script src="//netdna.bootstrapcdn.com/twitter-bootstrap/2.3.1/js/bootstrap.min.js"></script>
	<link href="http://netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css" rel="stylesheet">
	<script src="//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.5.2/underscore-min.js" type="text/javascript" charset="utf-8"></script>
	<script src="framework/chosen.jquery.min.js" type="text/javascript"></script>
	<script src="framework/spotify_genre.js" type="text/javascript"></script>
	<link rel="stylesheet" href="css/chosen.css" />
    <link href="css/spotify_styles_genre.css" rel="stylesheet">
</head>
<body background="images/web_background.jpg">
<table width="80%" border="0" align="center">
		<tr>
			<td height="80" colspan="2">
				<jsp:include flush="true" page="head.jsp"></jsp:include>
			</td>
		</tr>
		<tr>
			<td style=" padding: 15px">
				<div>
					<iframe width="420" height="345"
						src="http://www.youtube.com/embed/<%= urlKey%>">
					</iframe>
				</div>
			</td>
			<td style=" padding: 15px">
				<h1><%= song.getName()%></h1>
				<div id="all-info">
				    <div class="container">
				        <div id="the-main" class="span12 ">
				            <h1 class="gname"> </h1>
				            <div id="description-div">
				                <p>
				                <span id="description" class="lead">  </span>
				                <span id="wiki-div" class="pull-right"> Read more on <a id="wiki-link" href="">Wikipedia</a></span>
				                </p>
				            </div> 
				        </div>
				    </div>
				    <div class="container">
				        <div  id="similars" class="span12">
				            <h4> Similar Genres</h4>
				            <div class="list-container">
				                <ul id='similar-genres'> </ul>
				            </div>
				        </div>
				    </div>
				    <div class="container">
				        <div  class="span12 ">
				            <div>
				                <h4> Top <%= sGenre%> artists </h4>
				                <div id="artist-main" class="list-container">
				                    <ul id='artist-list'> </ul>
				                </div>
				            </div>
				        </div>
				    </div>
				    <div class="container">
				        <div  class="span12 ">
				            <!-- <div>
				                <h4> Top <span class="gname"></span> Songs </h4>
				                <div id="info" class=""> </div>
				                <div class="btn-group" data-toggle="buttons-radio">
				                    <button id="intro" title="Songs to introduce you to the genre" type="button" class="btn active">Core</button>
				                    <button id="current" title="Most popular songs being played today" type="button" class="btn">In rotation</button>
				                    <button id="discovery" title="Unexpectedly popular songs in the genre" type="button" class="btn">Emerging</button>
				                 </div>
				                  <div id="audio-buttons" class="btn-group pull-right">
				                        <button id="rp-play-prev" class="btn btn-primary btn-small">
				                            <i class="icon-backward"></i></button>
				                        <button id="rp-pause-play" class="btn btn-primary btn-small">
				                            <i class="icon-play"></i></button>
				                        <button id="rp-play-next" class="btn btn-primary btn-small">
				                            <i class="icon-forward"></i></button>
				                  </div>
				                    
				                    <button id="save-button" title="Save playlist to Spotify"
				                    type="button" class="btn pull-right">Save playlist</button>
				                <div id="song-main">
				                    <div id='song-list'> </div>
				                    <br style="clear:left;"/>
				                </div>
				            </div> -->
				        </div>
				    </div>
				  </div>
			</td>
			<td></td>
		</tr>
		<tr>
			<td height="80" colspan="2">
				<jsp:include flush="true" page="tail.jsp"></jsp:include>
			</td>
		</tr>
	</table>
</body>

<script type="text/javascript">

jQuery.ajaxSettings.traditional = true; 
var host = 'http://developer.echonest.com/api/v4/';
var apiKey =  'YTBBANYZHICTAFW2P';
var curSong = null;
var songTemplate = _.template($("#song-template").text());
var knownSongs = {};
var curGenre = null;
var curSongs = null;
var curStyle = null;
var deferredSongs = null;
var allGenres = {};
var genreList = ['rock'];
var fullGenreList = [];
var player;

function initUI() {
    $("#all-info").hide();

    $("#intro").click(function() {
        loadTopSongs(curGenre, 'core-best');
    });

    $("#current").click(function() {
        loadTopSongs(curGenre, 'in_rotation-best');
    });

    $("#discovery").click(function() {
        loadTopSongs(curGenre, 'emerging-best');
    });

    $("#save-button").click(savePlaylist);
    $("#choose-random").click(chooseRandomGenre);
}


function info(s) {
    $("#info").text(s);
    console.log('info:' + s);
}

function error(s) {
    $("#info").text(s);
    console.log('error:' + s);
}

function songChanged(song) {
    if (song) {
        var el = song.adiv.find('.adiv');

        var pause = el.find('.pause');
        var play = el.find('.play');

        if (song  === curSong) {
            el.addClass('is-current');
        } else {
            el.removeClass('is-current');
        }

        if (song === curSong && !player.paused()) {
            play.hide();
            pause.show();
        } else {
            play.show();
            pause.hide();
        }
    }
}

function getPlayer(song) {
    var minimumImageWidth = 200;
    var filteredImages = song.spotifyTrack.album.images.filter(function(i) {
        return i.width === null || i.width >= minimumImageWidth;
    });

    var playerInfo = {
        bigIcon: filteredImages.length ? filteredImages[filteredImages.length - 1].url : null,
        name:song.spotifyTrack.name,
        artist:song.spotifyTrack.artists[0].name
    };
    var el = $(songTemplate(playerInfo));

    var bypass = el.find('.bypass');
    bypass.hide();

    var buttons = el.find('.buttons');
    buttons.hide();

    var pause = el.find('.pause');
    var play = el.find('.play');

    play.click( function() {
        playSong(song);
    });

    pause.click( function() {
        playSong(song);
    });

    el.hover(
        function() {
            songChanged(song);
            buttons.show();
        },
        function() {
            buttons.hide();
        }
    );

    //el.find('.tooltips').tooltip({placement:'bottom', delay : 1500});
    return el;
}

function playSong(song) {
    if (song === curSong) {
        player.togglePause();
        songChanged(song);
    } else {
        player.playSong(song);
    }
}

function playNext() {
    if (curSong) {
        if (curSong.which + 1 < curSongs.length) {
            playSong(curSongs[curSong.which + 1]);
        } else {
            curSong = null;
        }
    } 
}


function showGenre(genreName) {
    $("#all-info").show();
    curGenre = genreName;
    var title = genreName;
    document.title = title;
    selectGenre(curGenre);
    /* setURL(curGenre); */
    showGenreInfo(genreName);
    loadSimilarGenres(genreName);
    loadTopArtists(genreName);
    loadTopSongs(genreName, 'core-best');
    tweetSetup();
}

function showGenreInfo(genreName) {
    var genre = allGenres[genreName];
    var songName = "<%= sName%>";
    $(".gname").text("Genre for "+songName+": "+genre.name);
    $("#description").text(genre.description);
    if ('wikipedia_url' in genre.urls) {
        $("#wiki-link").attr('href', genre.urls.wikipedia_url);
        $("#wiki-div").show();
    } else {
        $("#wiki-div").hide();
    }
}

function chooseRandomGenre() {
    var genre = genreList[Math.floor(Math.random()*genreList.length)];
    /* document.location= '?genre=' + genre.name; */
}

function getRandomFullGenre() {
    var genre = fullGenreList[Math.floor(Math.random()*fullGenreList.length)];
    return genre.name;
}


function loadTopArtists(genreName) {
    var url = host + 'genre/artists'
    $.getJSON(url, {api_key:apiKey, name:genreName },
        function(data) {
            var artists = data.response.artists;
            var list = $("#artist-list");
            list.empty();
            _.each(artists, function(artist, i) {
                var a = $("<a>").text(artist.name).attr('href', 'info_singer?singerName='+ artist.name);
                var li = $("<li>").append(a);
                list.append(li);
            });
        });
}

function loadSimilarGenres(genreName) {
    var url = host + 'genre/similar'
    $.getJSON(url, {api_key:apiKey, name:genreName },
        function(data) {
            var genres = data.response.genres;
            var list = $("#similar-genres");
            list.empty();
            if (genres.length > 0) {
                _.each(genres, function(genre, i) {
                    var a = $("<a>").text(genre.name).attr('href', '?genre='+genre.name);
                    var li = $("<li>").append(a).addClass('gna');
                    list.append(li);
                });
                $("#similars").show();
            } else {
                $("#similars").hide();
            }
        });
}

function loadTopSongs(genreName, preset) {
    info("");
    curStyle = preset.replace(/_/g, ' ');
    curStyle = curStyle.replace('-best', '');
    var url = host + 'playlist/static';
    $.getJSON(url, {api_key:apiKey, bucket:['tracks', 'id:spotify-WW'],    
                    limit:true, type:"genre-radio", 
                    results:12, 
                    genre_preset:preset,
                    genre:genreName },
        function(data) {
            var songs = data.response.songs;
            curSongs = songs;
            var list = $("#song-list");
            list.empty();
            _.each(songs, function(song, i) {
                song.which = i;
                var adiv = $("<div>");
                adiv.attr('class', 'tadiv');
                song.adiv = adiv;
                list.append(adiv);
            });
            player.addSongs(songs, function(song) {
                song.adiv.html(getPlayer(song));
            });
        });
}

function urldecode(str) {
   return decodeURIComponent((str+'').replace(/\+/g, '%20'));
}

function setURL(genre) {
    var p = '?genre=' + genre;
    history.replaceState({}, document.title, p);
}

function savePlaylist() {
    info("Saving the playlist");
}


function loadGenreList() {
    var url = "http://developer.echonest.com/api/v4/genre/list";
    $.getJSON(url, {api_key:apiKey, results:2000, bucket:["description", "urls"]}, function(data) {
        var glist = $('#genre');
        var noDescriptionCount = 0;
        genreList = data.response.genres;
        _.each(data.response.genres, function(genre, i) {
            genre.which = i;
            allGenres[genre.name] = genre;
            var opt = $("<option>").attr('value', genre.name).text(genre.name);
            glist.append(opt);

            if (genre.description.length == 0) {
                noDescriptionCount += 1;
            } else {
                fullGenreList.push(genre);
            }
        });
        /* console.log("Genres with no description " + noDescriptionCount);
        $(".chzn-select").chosen().change(function() {
            newGenre();
        }); */
        processParams();
    });
}

function newGenre() {
    var genre = $("#genre").val();
    /* if (genre.length > 0) {
        document.location= '?genre=' + genre;
    }  */
}

function selectGenre(name) {
    $('#genre').val(name);
    $('#genre').trigger("liszt:updated");
}

function tweetSetup() {
    $(".twitter-share-button").remove();
    var tweet = $('<a>')
        .attr('href', "https://twitter.com/share")
        .attr('id', "tweet")
        .attr('class', "twitter-share-button")
        .attr('data-lang', "en")
        .attr('data-size', "large")
        .attr('data-count', "none")
        .text('Tweet');

    $("#tweet-span").prepend(tweet);
    tweet.attr('data-text', 'Read about the genre ' + document.title + " at ");
    tweet.attr('data-url', document.URL);

    // twitter can be troublesome. If it is not there, don't bother loading it
    if ('twttr' in window) {
        twttr.widgets.load();
    }
}

function processParams() {
    var params = {};
    var q = document.URL.split('?')[1];
    if(q != undefined){
        q = q.split('&');
        for(var i = 0; i < q.length; i++){
            var pv = q[i].split('=');
            var p = pv[0];
            var v = pv[1];
            params[p] = urldecode(v);
        }
    }

    var genre = "<%= sGenre%>";
    if (genre == "") {
        genre = getRandomFullGenre();
    }
    /* showGenre(genre); */
    showGenre(genre);
}


$(document).ready(function() {
    $.ajaxSetup( {cache: true});
    $(".chzn-select").chosen();
    player = getSpotifyPlayer();
    player.setCallback(function(song) {
        console.log('cur song is', song);
        var oldSong = curSong;
        curSong = song;
        songChanged(oldSong);
        songChanged(curSong);
    });
    initUI();
    loadGenreList();
});

</script>


</html>
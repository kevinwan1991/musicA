<%@ page language="java" import="java.util.*" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<%@ page import="org.music.analysis.module.*"%>
<%
	ArrayList<Song> songList = (ArrayList<Song>) request.getAttribute("songList");
	Song song = songList.get(0);
	String songName = song.getName();
	
	//String songName = "";
	if(songName.length()>35){
		songName = songName.substring(0, 35);
	}
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<title>song_search</title>
	<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.0/jquery.min.js"></script>
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
    <link type="text/css" href="demo_styles.css" rel="stylesheet" />
    <link type="text/css" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css" rel="stylesheet"/>
    
    
</head>

<body>
 	<table width="80%" border="0" align="center">
		<tr>
		    <td height="80" colspan="2">
		      <!--Import head.jsp-->
		      <jsp:include flush="true" page="head.jsp"></jsp:include>
		    </td>
		</tr>
		<tr>
			<td width="50%">
				<form action="info_song" style="display:inline;">
					<input type = "text" name = "songName" />
	    			<input type="submit" value="search">
				</form>
		    </td>
		</tr>
		<tr>			
			<td style="width: 440px; display:inline-block">
    			<div id="info"></div>
    			<div id="all_results" align=left style="width:440px;margin:0 auto">
       				<div id='tracks'>
            			<h3> Playlist of <%= songName %></h3>
            			<div id="results"></div>
        			</div>
    			</div>
			</td>
			
			<td style="width: 82px; display:inline-block" valign="top">
				<div id="all_buttons">
				</div>
			</td>
			<td width="50%" valign="top">
				<h3> &nbsp Youtube Playlist of <%= songName %></h3>
				
				<table id="table_singer" width="630px" border="0">
					  <%
			          for(int i = 1; i < songList.size(); i++){
					  		String sName = "";
							String youtubeName = "";
							sName = songList.get(i).getName();
							youtubeName = songList.get(i).getYoutubeName();
			          %>
				          <tr align="left">
				          	<td width="30px" rowspan="1"><img id="sImg" src="images/nums/<%= i%>_mini.png"/></td> 
				          	<%-- <td width="40px" rowspan="2"><a href="info_song?songName=<%= sName %>"><img id="sImg" src="images/albums/<%= songName%>.jpg"/></a></td> --%>
				            <td width="600px"><a href="info_song?songName=<%= sName %>"><%= youtubeName %></a></td>
				          </tr>
				          <tr align="center">
				          	<td><%-- <%=songs.getSongList().get(i).getViews() %> --%></td>
				          </tr>
				      <%
				      }%>
				</table>
			    <div id="all_results_playList"> </div>
			</td>
		</tr>
		<tr>
		    <td height="60" colspan="2">
			  <!--Import head.jsp-->
			  <jsp:include flush="true" page="tail.jsp"></jsp:include>
		    </td>
		  </tr>
	</table>
</body>

<script type="text/javascript">

jQuery.ajaxSettings.traditional = true; 
var data1 = null;
var arrOfSongs = null;

var embed = '<iframe src="https://embed.spotify.com/?uri=spotify:trackset:PREFEREDTITLE:TRACKS" style="width:440px; height:520px;" frameborder="0" allowtransparency="true"></iframe>';

function searchArtist(sName, sID, callback) {
	var url = 'http://developer.echonest.com/api/v4/song/search';
	$("#all_results_playList").empty();
    info("Searching for the song ...");
    $.getJSON(url, {
            'api_key': "ICY4WXWWLLSRR8ZIX",
            'title' : sName,
            'bucket': [ 'id:spotify', 'tracks'],
            'limit' : true,
            'results': 2,
			'sort' : "song_hotttnesss-desc",        
          }) 
        .done(function(data) {
            info("");
            //callback(data);
            if (! ('songs' in data.response)) {
                console.log("Can't find that song!");
            } else {
            	data1 = data.response.songs;
            	callback(data1, sID, false, .2);
            }
        })
        .error( function() {
            info("Whoops, had some trouble finding that artist");
            console.log("Whoops, had some trouble finding that artist");
        }) ;
}

function fetchArtistPlaylist(arr, sID, wandering, variety) {
    var url = 'http://developer.echonest.com/api/v4/playlist/static';

    $("#all_results").hide();
    info("Creating the playlist ...");
    $.getJSON(url, { 
    	'song_id': sID, 
	    //'title': sName,
        'api_key': "ICY4WXWWLLSRR8ZIX",
        'bucket': [ 'id:spotify', 'tracks'], 
        'limit' : true,
        'variety' : 1,
        'results': 10, 
        'type':'song-radio'},function(data) {

            	 /* 'distribution' : wandering ? 'wandering' : 'focused' */
        info("");
        $("#results").empty();
        $("#all_results").show();

        var tracks = "";
        arrOfSongs = arr.concat(data.response.songs);
        for (var i = 0; i < arrOfSongs.length; i++) {
            var song = arrOfSongs[i];
            var tid = song.tracks[0].foreign_id.replace('spotify:track:', '');
            tracks = tracks + tid + ',';
        }
        var tembed = embed.replace('TRACKS', tracks);
        tembed = tembed.replace('PREFEREDTITLE', data.response.songs[0].title + ' playlist');
        var li = $("<span>").html(tembed);
        $("#results").append(li);
        
        $("#all_buttons").append(createPadding());
        
        for (var i = 0; i < arrOfSongs.length-1; i++) {
        	var song = arrOfSongs[i];
            var tid = song.tracks[0].foreign_id.replace('spotify:track:', '');
        	var simDiv = createButton(song.title,tid,song.artist_name);
        		if (simDiv) {
            	$("#all_buttons").append(simDiv);
        	}
        }
        var song = arrOfSongs[arrOfSongs.length-1];/* //data.response.songs[data.response.songs.length-1]; */
        var tid = song.tracks[0].foreign_id.replace('spotify:track:', '');
        $("#all_buttons").append(createButtonBottom(song.title,tid,song.artist_name));

    });
}

function createPadding(){
	var adiv = $("<div style=\"cursor:pointer\">");
	var img = $("<img height='80' width='36' style=\"margin-top:56px\">");
	img.attr('src', "images/black.png");
	   
    adiv.append(img); 
    return adiv;
}


function createButton(songName,trackID,singerName) {
       var adiv = $("<div style=\"cursor:pointer\">");
       //adiv.addClass('artist');
       //var aimg = $("<img style=\"cursor:pointer\" src=\"images/button.png\"  height='37' width='36' align='top' border='1' style=\"cursor: pointer\">");
       //adiv.appendChild($("<h4>").text(artist.name));
       adiv.attr('onclick',"window.location='http://localhost:8080/musicA/info_song?songName="+songName+"&"+"tid="+trackID+"&"+"singerName="+singerName+"';");
       var img = $("<img height='37' width='36'>");
       img.attr('src', "images/button.png");
	   //img.attr('href', "info_singer?singerName="+songName);
       adiv.append(img); 
             
       return adiv;
}

function createButtonBottom(songName,trackID,singerName) {
    var adiv = $("<div style=\"cursor:pointer\">");
    //adiv.addClass('artist');
    //var aimg = $("<img style=\"cursor:pointer\" src=\"images/button.png\"  height='37' width='36' align='top' border='1' style=\"cursor: pointer\">");
    //adiv.appendChild($("<h4>").text(artist.name));
    adiv.attr('onclick',"window.location='http://localhost:8080/musicA/info_song?songName="+songName+"&"+"tid="+trackID+"&"+"singerName="+singerName+"';");
    var img = $("<img height='33' width='36'>");
    img.attr('src', "images/button.png");
	//img.attr('href', "info_singer?singerName=taylor");
    adiv.append(img); 
          
    return adiv;
}

function newArtist() {
	<%-- alert("<%= songList.size()%>"); --%>
	var sID = "<%= song.getId() %>";
    var sName = "<%= song.getName() %>";
    var artist = $("#artist").val();
    searchArtist(sName, sID, function(arr){
    	fetchArtistPlaylist(arr, sID, false, .2);
    });
    
}

function info(txt) {
    $("#info").text(txt);
}


$(document).ready(function() {
	newArtist();
    $("#go").removeAttr("disabled");
    /*$("#all_results").hide(); */
});
</script>
</body>
</html>
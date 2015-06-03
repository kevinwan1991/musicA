<%@page contentType="text/html"  pageEncoding ="UTF-8" %> 
<%-- <%@ page language="java" import="java.util.*" pageEncoding="ISO-8859-1"%> --%>
<%@ page import="org.music.analysis.module.*" import="java.util.*" %>
<%
	Songs songs = new Songs();
	songs = (Songs) request.getAttribute("songs");
	//String str = (String) request.getAttribute("singers");
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<style type="text/css">
	table#table_singer tr:nth-child(even) {
    	background-color: #eee;
	}
	table#table_singer tr:nth-child(odd) {
		background-color:#fff;
	}
	.hot_list{
		width: 220px;
		background-color:#484545;
		padding:10px;
	}
</style>
<link type="text/css" href="http://netdna.bootstrapcdn.com/bootstrap/3.1.1/css/bootstrap.min.css" rel="stylesheet"/>

</head>
<body>
<div class="hot_list">
	<img src="images/hot_songs.png"/>
	<table id="table_singer" width="200px" border="0">
		<%
          for(int i = 0; i < 10; i++){ //songs.getSongList().size(); i++){
				String songName = "";
				String albumName = "";
				songName = songs.getSongList().get(i).getName();
				albumName = songs.getSongList().get(i).getAlbumBelong();
          %>
	          <tr align="center">
	          	<td width="30px" rowspan="2"><img id="sImg" src="images/nums/<%= i+1%>_mini.png"/></td>
	          	<td width="40px" rowspan="2"><a href="info_song?songName=<%= songName %>"><img id="sImg" src="images/albums/<%= songName%>.jpg"/></a></td>
	            <td width="130px"><%= songName %></td>
	          </tr>
	          <tr align="center">
	          	<td><%=songs.getSongList().get(i).getViews() %></td>
	          </tr>
	      <%
	      }%>
	</table>
</div>
</body>
</html>
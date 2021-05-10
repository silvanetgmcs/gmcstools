Option Explicit

Dim restReq, url, userName, password

Set restReq = CreateObject("Microsoft.XMLHTTP")
url="http://gmcsservice.gmcs.k12.nm.us:3000/sites"
restReq.open "GET", url, false
restReq.send
wscript.echo restReq.responseText
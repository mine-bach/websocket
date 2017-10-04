import QtQuick 2.0
import QtWebSockets 1.0

Rectangle {
    width: 360
    height: 360

    function appendMessage(message) {
        messageBox.text += "\n" + message
    }

    id : root
    property var allWS : []

    WebSocketServer {
        id: server
        port : 60606

        listen: true
        onClientConnected: {

            console.log( 'allWS.length = '+ allWS.length )

            webSocket.onTextMessageReceived.connect( function(message) {
                appendMessage(qsTr("Server received message: %1").arg(message));

                for( var t=0 ; t<allWS.length ; t++)
                {
                    console.log( 't = '+ t + "=>"+ (allWS[t] != webSocket) )
                    if( allWS[t] != webSocket )
                        allWS[t].sendTextMessage(qsTr("Received From Server Message : ")+ message );
                }
            } );

            webSocket.onStatusChanged.connect (function(status) {
                if( status == WebSocket.Closed )
                {
                    for( var t=0 ; t<allWS.length ; t++)
                    {
                        if( allWS[t] == webSocket )
                            allWS.splice(t, 1)
                    }
                }
                idConnected.text = allWS.length + " connected"
            } ) ;

            if( allWS.indexOf( webSocket)< 0 )
            {
                allWS.push( webSocket )
            }
            else
            {
                messageBox.text += "WS déjà présente dans tableau !"
                console.log( 'WS déjà présente dans tableau ! ')
            }

            idConnected.text = allWS.length + " connected"
        }

        onErrorStringChanged: {
            appendMessage(qsTr("Server error: %1").arg(errorString));
        }

        Component.onCompleted: console.log( "server.url = "+ server.url )
    }

    Rectangle{
        width : 200
        height : 40
        color : "gray"
        Text{
            id : idConnected
            anchors.fill: parent
            text : "new connexion"
            color: "white"
            font.pointSize: 14
            font.bold : true
            anchors.centerIn: parent
        }
    }

    Rectangle{
        width : 200
        height:  200

        y : 50
        color : "lavender"
        Text {
            id: messageBox
            text: qsTr("server.url : "+ server.url)
            anchors.fill: parent

            MouseArea {
                anchors.fill: parent
            }
        }

        Component.onCompleted: {
            console.log( 'lavender completed' )
        }
    }
}

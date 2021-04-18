package main

import (
	"ColorOppositeServer/arena"
	"ColorOppositeServer/lobby"
	"ColorOppositeServer/shared"
	"context"
	"log"
	"net/http"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:    4096,
	WriteBufferSize:   4096,
	EnableCompression: true,
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

var Lobby = lobby.NewLobby(onMatch)
var Arena = arena.NewArena(roomResult)

func onMatch(left *websocket.Conn, leftPlayer *shared.Player, right *websocket.Conn, rightPlayer *shared.Player) {
	go Arena.CreateRoom(left, leftPlayer, right, rightPlayer)
}

func roomResult(left *shared.Player, right *shared.Player, winner int, result arena.RoomResult) {

}

func main() {
	http.HandleFunc("/ws", wsHandle)
	ctx := context.Background()
	go Lobby.Run(ctx)
	go Arena.Run(ctx)
	http.ListenAndServe("127.0.0.1:80", nil)
}

func wsHandle(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("Upgrade:", err)
		return
	}
	player := &shared.Player{}
	go Lobby.Connect(conn, player)
}

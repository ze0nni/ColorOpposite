package arena

import (
	"ColorOppositeServer/shared"

	"github.com/gorilla/websocket"
)

type player struct {
	conn   *websocket.Conn
	player *shared.Player
	teamId int
	score  int
	turns  int
}

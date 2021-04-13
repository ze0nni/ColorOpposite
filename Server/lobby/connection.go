package lobby

import (
	"ColorOppositeServer/shared"

	"github.com/gorilla/websocket"
)

type connection struct {
	ws     *websocket.Conn
	player *shared.Player
}

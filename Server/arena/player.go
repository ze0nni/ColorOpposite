package arena

import (
	"ColorOppositeServer/shared"
	"sync"

	"github.com/gorilla/websocket"
)

type player struct {
	lock sync.Mutex

	conn   *websocket.Conn
	player *shared.Player
	teamId int
	score  int
	turns  int

	timeout bool

	queue []clientCommand
}

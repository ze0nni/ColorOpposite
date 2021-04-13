package arena

import (
	"ColorOppositeServer/shared"
	"context"
	"log"
	"sync"

	"github.com/gorilla/websocket"
)

func NewArena(handler RoomDoneHandler) *Arena {
	return &Arena{
		roomsWG: &sync.WaitGroup{},
		handler: handler,
	}
}

type RoomResult int

const RoomResultDraw = RoomResult(2)
const RoomResultLeft = RoomResult(1)
const RoomResultRight = RoomResult(2)
const RoomResultFoul = RoomResult(3)

type RoomDoneHandler func(*shared.Player, *shared.Player, RoomResult)

type Arena struct {
	roomsWG *sync.WaitGroup

	handler RoomDoneHandler
}

func (a *Arena) Run(ctx context.Context) {
	log.Println("Run Arena")
	<-ctx.Done()
	log.Println("Stopping Arena...")
	a.roomsWG.Wait()
	log.Println("Stop Arena")
}

func (a *Arena) CreateRoom(
	left *websocket.Conn,
	leftPlayer *shared.Player,
	right *websocket.Conn,
	rightPlayer *shared.Player) {
	a.roomsWG.Add(1)
	defer a.roomsWG.Done()

	var result RoomResult
gameLoop:
	for {
		var lCmd command
		var rCmd command

		err := left.ReadJSON(&lCmd)
		if err != nil {
			result = RoomResultFoul
			break gameLoop
		}
		err = right.ReadJSON(&rCmd)
		if err != nil {
			result = RoomResultFoul
			break gameLoop
		}
		if lCmd != rCmd {
			result = RoomResultFoul
			break gameLoop
		}
		switch lCmd.Cmd {
		case "touch":
		case "hash":
		case "bonusTurn":
		}
	}
	a.handler(leftPlayer, rightPlayer, result)
}

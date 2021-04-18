package arena

import (
	"ColorOppositeServer/shared"
	"context"
	"log"
	"sync"
	"time"

	"github.com/gorilla/websocket"
)

func NewArena(handler RoomDoneHandler) *Arena {
	return &Arena{
		roomsWG: &sync.WaitGroup{},
		handler: handler,
	}
}

type RoomResult int

const RoomResultDraw = RoomResult(0)
const RoomResultDone = RoomResult(1)
const RoomResultAuto = RoomResult(2)
const RoomResultFoul = RoomResult(3)

type RoomDoneHandler func(*shared.Player, *shared.Player, int, RoomResult)

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
	rightPlayer *shared.Player,
) {
	p1 := &player{
		conn:   left,
		player: leftPlayer,
		teamId: 1,
	}
	p2 := &player{
		conn:   right,
		player: rightPlayer,
		teamId: 2,
	}

	room := newRoom(p1, p2)
	a.roomsWG.Add(1)
	defer a.roomsWG.Done()
	defer left.Close()
	defer right.Close()
	result, winner, err := room.Play()
	if err != nil {
		log.Printf("Room error %s", err)
	}

	var roomResultCmd roomResultCommand
	roomResultCmd.Cmd = "roomResult"
	roomResultCmd.Winner = winner
	roomResultCmd.Result = result

	left.WriteJSON(&roomResultCmd)
	right.WriteJSON(&roomResultCmd)

	a.handler(leftPlayer, rightPlayer, winner, result)

	time.Sleep(time.Second / 2)
	time.Sleep(time.Second / 2)
}

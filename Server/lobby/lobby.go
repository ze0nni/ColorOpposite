package lobby

import (
	"ColorOppositeServer/shared"
	"context"
	"log"
	"sync"
	"time"

	"github.com/gorilla/websocket"
)

const MatchmakeBufferSize = 256

type OnMatch func(*websocket.Conn, *shared.Player, *websocket.Conn, *shared.Player)

func NewLobby(onMatch OnMatch) *Lobby {
	return &Lobby{
		connections: make(map[*connection]struct{}),
	}
}

type Lobby struct {
	onMatch OnMatch

	connectionsLock sync.Mutex
	connections     map[*connection]struct{}

	matchmakeBuffer []*connection
}

func (l *Lobby) Run(ctx context.Context) {
	log.Println("Run Lobby")
	t := time.NewTicker(time.Second)
lobbyLoop:
	for {
		<-t.C

		select {
		case <-ctx.Done():
			break lobbyLoop
		default:
		}

		l.keepAlive()
		l.match()
	}
	t.Stop()
	log.Println("Stop Lobby")
}

func (l *Lobby) Connect(ws *websocket.Conn, player *shared.Player) {
	log.Printf("Lobby Connect: %s", ws.RemoteAddr().String())

	var handshake struct {
		command string
		token   string
	}

	err := ws.ReadJSON(&handshake)
	if err != nil {
		log.Printf("Handshake error %s", err)
		ws.Close()
		return
	}

	conn := &connection{
		ws:     ws,
		player: player,
	}

	l.connectionsLock.Lock()
	defer l.connectionsLock.Unlock()
	l.connections[conn] = struct{}{}
}

func (l *Lobby) keepAlive() {
	//TODO
}

func (l *Lobby) match() {
	if l.matchmakeBuffer == nil {
		l.matchmakeBuffer = make([]*connection, MatchmakeBufferSize)
	}
	l.connectionsLock.Lock()
	defer l.connectionsLock.Unlock()

	index := 0
	for conn, _ := range l.connections {
		if index >= MatchmakeBufferSize {
			break
		}
		l.matchmakeBuffer[index] = conn
		index++
	}
	//TODO: Shuffle matchmakeBuffer
	for i := 0; i < index/2; i++ {
		left := l.matchmakeBuffer[i*2]
		right := l.matchmakeBuffer[i*2+1]
		delete(l.connections, left)
		delete(l.connections, right)
		l.onMatch(left.ws, left.player, right.ws, right.player)
	}
}

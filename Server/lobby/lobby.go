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
		onMatch:     onMatch,
		connections: []*connection{},
	}
}

type Lobby struct {
	onMatch OnMatch

	connectionsLock sync.Mutex
	connections     []*connection
}

func (l *Lobby) Run(ctx context.Context) {
	log.Println("Run Lobby")
	t := time.NewTicker(time.Second * 3)
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
	l.connections = append(l.connections, conn)
}

func (l *Lobby) keepAlive() {
	var keepAlive struct {
		Command string `json:"command"`
	}
	keepAlive.Command = "keepAlive"

	for i := len(l.connections) - 1; i >= 0; i-- {
		var conn = l.connections[i]
		err := conn.ws.WriteJSON(&keepAlive)
		if err == nil {
			continue
		}
		l.connections = append(l.connections[:i], l.connections[i+1:]...)

		log.Printf("KeepAlive error: %s", err)
		log.Printf("Disconnected %s", conn.ws.RemoteAddr().String())
	}
}

func (l *Lobby) match() {
	l.connectionsLock.Lock()
	defer l.connectionsLock.Unlock()
	//TODO: Shuffle matchmakeBuffer
	matches := 0
	for i := 0; i < len(l.connections)-1; i++ {
		left := l.connections[i]
		right := l.connections[i+1]
		l.connections = append(l.connections[:i], l.connections[i+2:]...)
		matches++
		l.onMatch(left.ws, left.player, right.ws, right.player)
	}
	if matches > 0 {
		log.Printf("Matched: %d", matches)
	}
}

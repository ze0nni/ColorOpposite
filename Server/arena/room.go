package arena

import (
	"errors"
)

func newRoom(left *player, right *player) *room {
	return &room{
		left:  left,
		right: right,
	}
}

type room struct {
	left  *player
	right *player
}

func (r *room) otherPlayer(this *player) *player {
	if this == r.left {
		return r.right
	} else {
		return r.left
	}
}

func (r *room) Play() (RoomResult, error) {

	startGameCmd := &startGame{}
	startGameCmd.Cmd = "startGame"
	startGameCmd.Seed = 0

	startGameCmd.TeamId = 1
	err := r.left.conn.WriteJSON(&startGameCmd)
	if err != nil {
		return RoomResultFoul, err
	}

	startGameCmd.TeamId = 2
	err = r.right.conn.WriteJSON(&startGameCmd)
	if err != nil {
		return RoomResultFoul, err
	}
	cmdChan := make(chan struct{})
	errorCh := make(chan error)

	go r.readPlayerInput(r.left, cmdChan, errorCh)
	go r.readPlayerInput(r.right, cmdChan, errorCh)

	for {
		select {
		case <-cmdChan:
			err = r.performCommands()
			if err != nil {
				return RoomResultFoul, err
			}
		case err = <-errorCh:
			return RoomResultFoul, err
		}
	}
}

func (r *room) readPlayerInput(p *player, input chan<- struct{}, errorCh chan<- error) {
	for {
		var cmd command
		err := p.conn.ReadJSON(&cmd)
		if err != nil {
			errorCh <- err
			return
		}
		r.left.lock.Lock()
		r.right.lock.Lock()

		switch cmd.Cmd {
		case "touch":
			var touchCmd touchCommand
			err = p.conn.ReadJSON(&touchCmd)
			if err != nil {
				errorCh <- err
				return
			}
			touchCmd.Cmd = "touch"
			r.otherPlayer(p).conn.WriteJSON(touchCmd)
		case "hash":
		}

		r.left.lock.Unlock()
		r.right.lock.Unlock()
	}
}

func (r *room) performCommands() error {
	r.left.lock.Lock()
	r.right.lock.Lock()
	defer r.left.lock.Unlock()
	defer r.right.lock.Unlock()
	for len(r.left.queue) > 0 &&
		len(r.right.queue) > 0 {
		left := r.left.queue[0]
		r.left.queue = r.left.queue[1:]
		right := r.left.queue[0]
		r.right.queue = r.right.queue[1:]
		if left.Name() != right.Name() {
			return errors.New("command names not match")
		}
		left.Apply(r, r.left)
		right.Apply(r, r.right)
		//TODO check conditions
	}
	return nil
}

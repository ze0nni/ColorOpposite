package arena

import (
	"errors"
	"time"
)

const Rounds = 3
const RountTurns = 3
const TurnTime = 15
const RoundsCount = 3

func newRoom(left *player, right *player) *room {
	left.turns = RountTurns
	return &room{
		left:  left,
		right: right,
	}
}

type room struct {
	left          *player
	right         *player
	currentPlayer *player

	round int
}

func (r *room) otherPlayer(this *player) *player {
	if this == r.left {
		return r.right
	} else {
		return r.left
	}
}

func (r *room) Play() (RoomResult, int, error) {

	startGameCmd := &startGame{}
	startGameCmd.Cmd = "startGame"
	startGameCmd.Seed = int(time.Now().Unix())
	startGameCmd.Rounds = Rounds
	startGameCmd.TurnsForRound = RountTurns

	startGameCmd.TeamId = 1
	err := r.left.conn.WriteJSON(&startGameCmd)
	if err != nil {
		return RoomResultFoul, 2, err
	}

	startGameCmd.TeamId = 2
	err = r.right.conn.WriteJSON(&startGameCmd)
	if err != nil {
		return RoomResultFoul, 1, err
	}
	cmdChan := make(chan struct{})
	errorCh := make(chan error)

	go r.readPlayerInput(r.left, cmdChan, errorCh)
	go r.readPlayerInput(r.right, cmdChan, errorCh)

	ticker := time.NewTicker(time.Second)
	defer ticker.Stop()
	for {
		select {
		case <-cmdChan:
			err = r.performCommands()
			if err != nil {
				return RoomResultFoul, 0, err
			}

		case <-ticker.C:
			//

		case err = <-errorCh:
			return RoomResultFoul, 0, err
		}

		result, teamId, ok, err := r.checkEndGame()
		if err != nil {
			return result, 0, err
		}
		if ok {
			return result, teamId, nil
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
		p.lock.Lock()

		switch cmd.Cmd {
		case "touch":
			if r.currentPlayer != p {
				errorCh <- errors.New("Not current player")
			}
			if p.turns <= 0 {
				errorCh <- errors.New("No more turns")
			}
			p.turns -= 1

			var touchCmd touchCommand
			err = p.conn.ReadJSON(&touchCmd)
			if err != nil {
				errorCh <- err
				return
			}
			touchCmd.Cmd = "touch"
			r.otherPlayer(p).conn.WriteJSON(touchCmd)

		case "score":
			var scoreCmd scoreCommand
			err = p.conn.ReadJSON(&scoreCmd)
			if err != nil {
				errorCh <- err
				return
			}
			if scoreCmd.TeamId == p.teamId {
				p.score = scoreCmd.Score
			}

		case "timeout":
			p.timeout = true

		case "hash":
			var hashCmd clientHashCommand
			p.conn.ReadJSON(&hashCmd)
			p.queue = append(p.queue, &hashCmd)
			input <- struct{}{}
		}

		p.lock.Unlock()
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

		right := r.right.queue[0]
		r.right.queue = r.right.queue[1:]

		if left.Name() != right.Name() {
			return errors.New("command names not match")
		}
		left.Apply(r, r.left)
		right.Apply(r, r.right)

		if left.Name() == "hash" {
			return r.handleEndturn()
		}
	}
	return nil
}

func (r *room) handleEndturn() error {
	if r.currentPlayer == nil || r.currentPlayer.turns == 0 {
		if r.currentPlayer != nil {
			r.currentPlayer = r.otherPlayer(r.currentPlayer)
		} else {
			r.currentPlayer = r.left
		}
		r.currentPlayer.turns = RountTurns
		if r.currentPlayer == r.left {
			r.round += 1
		}
		var currentRoundCmd currentRoundCommand
		currentRoundCmd.Cmd = "currentRound"
		currentRoundCmd.Round = r.round
		currentRoundCmd.TeamId = r.currentPlayer.teamId
		currentRoundCmd.TurnTime = TurnTime

		err := r.left.conn.WriteJSON(&currentRoundCmd)
		if err != nil {
			return err
		}

		err = r.right.conn.WriteJSON(&currentRoundCmd)
		if err != nil {
			return err
		}
	} else {
		var currentTurnCmd currentTurnCommand
		currentTurnCmd.Cmd = "currentTurn"
		currentTurnCmd.TeamId = r.currentPlayer.teamId

		err := r.left.conn.WriteJSON(&currentTurnCmd)
		if err != nil {
			return err
		}

		err = r.right.conn.WriteJSON(&currentTurnCmd)
		if err != nil {
			return err
		}
	}
	r.left.timeout = false
	r.right.timeout = false
	return nil
}

func (r *room) checkEndGame() (RoomResult, int, bool, error) {
	if r.round > RoundsCount {
		if r.left.score == r.right.score {
			return RoomResultDraw, 0, true, nil
		}
		if r.left.score > r.right.score {
			return RoomResultDone, 1, true, nil
		} else {
			return RoomResultDone, 2, true, nil
		}
	}

	var keepAlive struct {
		Command string `json:"command"`
	}
	keepAlive.Command = "keepAlive"

	if r.left.conn.WriteJSON(&keepAlive) != nil {
		return RoomResultAuto, 2, true, nil
	}

	if r.right.conn.WriteJSON(&keepAlive) != nil {
		return RoomResultAuto, 1, true, nil
	}

	if r.currentPlayer != nil && r.currentPlayer.timeout {
		r.currentPlayer.turns = 0
		err := r.handleEndturn()
		if err != nil {
			return RoomResultFoul, 0, false, err
		}
	}

	return RoomResultDraw, 0, false, nil
}

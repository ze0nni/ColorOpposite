package arena

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

func (r *room) Play() (RoomResult, error) {

	startGameCmd := &startGame{}
	startGameCmd.Cmd = "startGame"
	startGameCmd.Seed = 0

	var result RoomResult

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

	//gameLoop:
	for result != RoomResultFoul {
	}

	return result, nil
}

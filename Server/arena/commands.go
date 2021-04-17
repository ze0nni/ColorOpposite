package arena

type command struct {
	Cmd string `json:"command"`
}

type startGame struct {
	command
	Seed   int `json:"seed"`
	TeamId int `json:"teamId"`

	Rounds        int `json:"rounds"`
	TurnsForRound int `json:"turnsForRound"`
}

type touchCommand struct {
	command
	X int `json:"x"`
	Y int `json:"y"`
}

type scoreCommand struct {
	TeamId int `json:"teamId"`
	Score  int `json:"score"`
}

type currentRoundCommand struct {
	command
	TeamId   int `json:"teamId"`
	TurnTime int `json:"turnTime"`
}

type currentTurnCommand struct {
	command
	TeamId int `json:"teamId"`
}

type roomResultCommand struct {
	command
	Result RoomResult `json:"result"`
}

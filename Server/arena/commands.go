package arena

type command struct {
	Cmd string `json:"command"`
}

type startGame struct {
	command
	Seed   int `json:"seed"`
	TeamId int `json:"teamId"`
}

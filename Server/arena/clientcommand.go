package arena

type clientCommand interface {
	Name() string
	Apply(room *room, player *player)
}

type clientHashCommand struct {
	Hash int `json:"hash"`
}

func (c *clientHashCommand) Name() string {
	return "hash"
}

func (c *clientHashCommand) Apply(room *room, player *player) {

}

package arena

type clientCommand interface {
	Name() string
	Apply(room *room, player *player)
}

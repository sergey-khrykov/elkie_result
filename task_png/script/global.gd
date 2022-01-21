extends Node


const CELL_PIXELS = 64
const BOARD_SIZE = 8
const CHECKER_ROWS = 3

enum PLAYER {
	BLACK = 0,
	WHITE = 1,
	EMPTY = -1,
}

func get_opponent(player):
	return (player + 1) % 2

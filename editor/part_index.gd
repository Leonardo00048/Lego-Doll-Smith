# part_index.gd
extends Node

## 全局零件场景资源映射 (Key格式: 前缀+编号)
const PART_SCENES := {
	"br3004": preload("res://part_tscn/brick/br3004.tscn"),
	"br3009": preload("res://part_tscn/brick/br3009.tscn"),
	"br3010": preload("res://part_tscn/brick/br3010.tscn"),
	"br3065": preload("res://part_tscn/brick/br3065.tscn"),
	"br3066": preload("res://part_tscn/brick/br3066.tscn"),
	"br3001": preload("res://part_tscn/brick/br3001.tscn"),
	"br2357": preload("res://part_tscn/brick/br2357.tscn"),
	"br2456": preload("res://part_tscn/brick/br2456.tscn"),
	"br3245b": preload("res://part_tscn/brick/br3245b.tscn"),
		
	"brmo11211": preload("res://part_tscn/brick,modified/brmo11211.tscn"),
	"brmo22885": preload("res://part_tscn/brick,modified/brmo22885.tscn"),
	
	"bk44728": preload("res://part_tscn/bracket/bk44728.tscn"),

	"brro3941": preload("res://part_tscn/brick,round/brro3941.tscn"),
	
	"pl2420": preload("res://part_tscn/plate/pl2420.tscn"),
	"pl3020": preload("res://part_tscn/plate/pl3020.tscn"),
	"pl3022": preload("res://part_tscn/plate/pl3022.tscn"),
	"pl3023": preload("res://part_tscn/plate/pl3023.tscn"),
	"pl3024": preload("res://part_tscn/plate/pl3024.tscn"),
	"pl3031": preload("res://part_tscn/plate/pl3031.tscn"),
	"pl3032": preload("res://part_tscn/plate/pl3032.tscn"),
	"pl3623": preload("res://part_tscn/plate/pl3623.tscn"),
	"pl3666": preload("res://part_tscn/plate/pl3666.tscn"),	
	"pl3710": preload("res://part_tscn/plate/pl3710.tscn"),
	"pl3795": preload("res://part_tscn/plate/pl3795.tscn"),
	
	"plmo14417": preload("res://part_tscn/plate,modified/plmo14417.tscn"),
	"plmo14704": preload("res://part_tscn/plate,modified/plmo14704.tscn"),
	
	"sl3039": preload("res://part_tscn/slope/sl3039.tscn"),
	"sl85984": preload("res://part_tscn/slope/sl85984.tscn"),	
	
	"slcu6215": preload("res://part_tscn/slope,curved/slcu6215.tscn"),
	"slcu11477": preload("res://part_tscn/slope,curved/slcu11477.tscn"),
	"slcu15068": preload("res://part_tscn/slope,curved/slcu15068.tscn"),
	"slcu32803": preload("res://part_tscn/slope,curved/slcu32803.tscn"),
	"slcu88930": preload("res://part_tscn/slope,curved/slcu88930.tscn"),

	"slin2449": preload("res://part_tscn/slope,inverted/slin2449.tscn"),
	"slin3665": preload("res://part_tscn/slope,inverted/slin3665.tscn"),
	
	"ti2431": preload("res://part_tscn/tile/ti2431.tscn"),
	"ti87079": preload("res://part_tscn/tile/ti87079.tscn"),
	
	"teax43093": preload("res://part_tscn/technique,axle/teax43093.tscn"),
	
	"tebr3700": preload("res://part_tscn/technique,brick/tebr3700.tscn"),
	"tebr57909b": preload("res://part_tscn/technique,brick/tebr57909b.tscn"),
	"tebr67696": preload("res://part_tscn/technique,brick/tebr67696.tscn"),
	
	"tepi32556": preload("res://part_tscn/technique,pin/tepi32556.tscn")
	
}	

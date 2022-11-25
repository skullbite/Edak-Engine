// this is from a mod i worked on
char.barColor = "0xa1a1a1";

char.loadGraphic(_Paths.image("week54prototype", "shared"));
char.displaceData.y = 300;
				
char.animation.add("singLEFT", [0], 0);
char.animation.add("singRIGHT", [0], 0);
char.animation.add("singUP", [0], 0);
char.animation.add("singDOWN", [0], 0);
char.animation.add("idle", [0], 0);

char.animation.callback = (n, i, d) -> {
	switch (n) {
		case "singLEFT": char.color = 0x8f3571;
		case "singRIGHT": char.color = 0xcb2e33;
		case "singUP": char.color = 0x1fc106;
		case "singDOWN": char.color = 0x24bdbd;
		case "idle": char.color = 0xffffff;
	}
};

char.playAnim('idle');
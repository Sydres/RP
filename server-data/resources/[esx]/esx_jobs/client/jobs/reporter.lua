Config.Jobs.reporter = {

	BlipInfos = {
		Sprite = 184,
		Color = 1
	},

	Vehicles = {

		Truck = {
			Spawner = 1,
			Hash = "rumpo",
			Trailer = "none",
			HasCaution = true
		}

	},

	Zones = {

		VehicleSpawner = {
			Pos = {x = -543.7, y = -890.07, z = 23.97},
			Size = {x = 2.0, y = 2.0, z = 0.2},
			Color = {r = 204, g = 204, b = 0},
			Marker = 1,
			Blip = true,
			Name = _U("reporter_name"),
			Type = "vehspawner",
			Spawner = 1,
			Hint = _U("reporter_garage"),
			Caution = 2000
		},

		VehicleSpawnPoint = {
			Pos = {x = -543.82, y = -901.18, z = 23.92},
			Size = {x = 3.0, y = 3.0, z = 1.0},
			Marker = -1,
			Blip = false,
			Name = _U("service_vh"),
			Type = "vehspawnpt",
			Spawner = 1,
			Heading = 170.24
		},

		VehicleDeletePoint = {
			Pos = {x = -532.65, y = -889.56, z = 23.85},
			Size = {x = 5.0, y = 5.0, z = 0.2},
			Color = {r = 255, g = 0, b = 0},
			Marker = 1,
			Blip = false,
			Name = _U("return_vh"),
			Type = "vehdelete",
			Hint = _U("return_vh_button"),
			Spawner = 1,
			Caution = 2000,
			GPS = 0,
			Teleport = {x = -538.78, y = -889.83, z = 24.97}
		}

	}
}

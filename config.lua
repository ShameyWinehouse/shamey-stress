Config = {}

Config.Debug = false
Config.PrintDebug = false

Config.MinimumStress = 500

Config.Intensity = {
    ["shake"] = {
        [1] = {
            min = 500,
            max = 600,
            intensity = 0.12,
        },
        [2] = {
            min = 600,
            max = 700,
            intensity = 0.17,
        },
        [3] = {
            min = 700,
            max = 800,
            intensity = 0.22,
        },
        [4] = {
            min = 800,
            max = 900,
            intensity = 0.28,
        },
        [5] = {
            min = 900,
            max = 1000,
            intensity = 0.32,
        },
    }
}

Config.EffectInterval = {
    [1] = {
        min = 500,
        max = 600,
        timeout = math.random(50000, 60000)
    },
    [2] = {
        min = 600,
        max = 700,
        timeout = math.random(40000, 50000)
    },
    [3] = {
        min = 700,
        max = 800,
        timeout = math.random(30000, 40000)
    },
    [4] = {
        min = 800,
        max = 900,
        timeout = math.random(20000, 30000)
    },
    [5] = {
        min = 900,
        max = 1000,
        timeout = math.random(15000, 20000)
    }
}

Config.JobsImmuneToWeaponStress = {
	"gunsmith",
}
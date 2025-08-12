--!strict
return table.freeze {
    LongName = 'Custom Emote Thumbnail',
    ShortName = 'CET',
    Version = '0.1.0',

    CameraFOV = 20,
    MannequinOutfitId = 1342485078, -- Bundle: 515

    DefaultParameters = table.freeze {
        ThumbnailKeyframe = 1,
        ThumbnailTime = 0,
        ThumbnailZoom = 1,
        
        ThumbnailVerticalOffset = 0,
        ThumbnailHorizontalOffset = 0,
        ThumbnailCharacterRotation = 0,
    },

    ParamMapping = table.freeze {
        KeyFrame = "ThumbnailKeyframe",
        Time = "ThumbnailTime",
        Zoom = "ThumbnailZoom",

        VerticalOffset = "ThumbnailVerticalOffset",
        HorizontalOffset = "ThumbnailHorizontalOffset",
        Rotation = "ThumbnailCharacterRotation",
    },

    ParamConfig = table.freeze {
        Time = table.freeze {
            Min = 0
        },
        KeyFrame = table.freeze {
            Min = 1,
            Step = 1,
        },
        Rotation = table.freeze {
            Min = 0,
            Max = 360,
            Format = function(input: number) return input % 360  end
        },
        Zoom = table.freeze {
            Min = 0,
        },
    },

    HoldThreshold = .5,
    RepeatInterval = .1,

    PadIncrement = .05,
    RotateIncrement = 5,
    ZoomIncrement = .05,

    CurveIncrement = .01,
    KeyIncrement = 1,
}
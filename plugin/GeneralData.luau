--!strict
return table.freeze {
    LongName = 'Custom Emote Thumbnail',
    ShortName = 'CET',
    Version = '0.1.3',

    CameraFOV = 20,

    FixMeshIds = table.freeze {
        Head = 'https://assetdelivery.roblox.com/v1/asset/?id=7278806860',
        LeftFoot = 'https://www.roblox.com/asset/?id=3575898930',
        LeftHand = 'https://www.roblox.com/asset/?id=3575898827',
        LeftLowerArm = 'https://www.roblox.com/asset/?id=3575898824',
        LeftLowerLeg = 'https://www.roblox.com/asset/?id=3575898961',
        LeftUpperArm = 'https://www.roblox.com/asset/?id=3575898826',
        LeftUpperLeg = 'https://www.roblox.com/asset/?id=3575898963',
        LowerTorso = 'https://www.roblox.com/asset/?id=3575899033',
        RightFoot = 'https://www.roblox.com/asset/?id=3575898968',
        RightHand = 'https://www.roblox.com/asset/?id=3575898823',
        RightLowerArm = 'https://www.roblox.com/asset/?id=3575898821',
        RightLowerLeg = 'https://www.roblox.com/asset/?id=3575898998',
        RightUpperArm = 'https://www.roblox.com/asset/?id=3575898879',
        RightUpperLeg = 'https://www.roblox.com/asset/?id=3575899011',
        UpperTorso = 'https://www.roblox.com/asset/?id=3575898880',
    },

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
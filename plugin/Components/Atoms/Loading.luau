--!strict
local RunService = game:GetService("RunService")

local MainPath = script.Parent.Parent.Parent
local Fusion = require(MainPath.Packages.Fusion)

local peek = Fusion.peek
local DefaultSpeed = 180

export type Props = {
    Size: UDim2,
    Position: UDim2?,
    AnchorPoint: Vector2?,
    SizeConstraint: Enum.SizeConstraint?,

    Visible: Fusion.Value<boolean>?,
    Speed: Fusion.UsedAs<number>?,
}

return function(scope: Fusion.Scope<Fusion.Fusion>, props: Props): Frame
    local timer = scope:Value(os.clock())
    local conn: RBXScriptConnection?

    table.insert(scope, function()
        if not conn then return end
        conn = conn:Disconnect()
    end)

    local function toggleConn(to: boolean)
        if to then
            if conn then return end
            conn = RunService.Heartbeat:Connect(function()
                timer:set(os.clock())
            end)
        else
            conn = conn and conn:Disconnect()
        end
    end

    if typeof(props.Visible)=='table' and props.Visible.kind == 'State' then
        local function onChange() toggleConn(peek(props.Visible)) end
        scope:Observer(props.Visible):onChange(onChange)
        onChange()
    else
        toggleConn(if props.Visible and typeof(props.Visible) == 'boolean'then props.Visible else true)
    end

    return scope:New 'Frame' {
        Name = script.Name,
        Visible = props.Visible or true,
        BackgroundTransparency = 1,

        Size = props.Size,
        Position = props.Position or UDim2.new(),
        AnchorPoint = props.AnchorPoint or Vector2.zero,
        SizeConstraint = props.SizeConstraint or Enum.SizeConstraint.RelativeXY,

        [Fusion.Children] = scope:New 'ImageLabel' {
            Name = "Icon",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Rotation = scope:Computed(function(use)
                return (use(timer) * (use(props.Speed) or DefaultSpeed)) % 360
            end),

            Image = "rbxassetid://10723433935",
            ScaleType = Enum.ScaleType.Fit,
        }
    } :: Frame
end
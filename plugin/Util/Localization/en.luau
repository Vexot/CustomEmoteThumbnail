--!strict
return table.freeze {
    plugin_name = 'Custom Emote Thumbnail',
    plugin_btn = 'Toggle Widget',
    plugin_btnTooltip = 'Toggle the Custom Emote Thumbnail widget',

    action_save = 'Save',
    action_resetParams = 'Reset params',

    value_keyframe = 'Keyframe ({current}/{total})',
    value_range = 'Max: {max}, Min: {min}',

    param_zoom = 'Zoom',
    param_verticaloffset = 'Vertical Offset',
    param_horizontaloffset = 'Horizontal Offset',
    param_rotation = 'Rotation',

    view_simplified = 'Simplified',
    view_advanced = 'Advanced',

    warning_update = `There's a new version available! Please visit GitHub and update to the latest version.`,
    warning_selection = 'You must select a single <b>Animation</b> instance before updating its thumbnail',
    warning_earlyaccess = '⚠️ Remember to press <b>Save</b> when finished.<br/><br/>'
        .. 'This plugin is in early development. If you encounter any issues, please report them on the GitHub repository.'
}

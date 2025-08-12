--!strict
return table.freeze {
    plugin_name = 'Miniatura Personalizada para Emotes',
    plugin_btn = 'Alternar Widget',
    plugin_btnTooltip = 'Alternar el widget de Miniatura Personalizada para Emotes',

    action_save = 'Guardar',
    action_resetParams = 'Restablecer',

    value_keyframe = 'Fotograma ({current}/{total})',
    value_range = 'Máx: {max}, Mín: {min}',

    param_zoom = 'Zoom',
    param_verticaloffset = 'Desplazamiento Vertical',
    param_horizontaloffset = 'Desplazamiento Horizontal',
    param_rotation = 'Rotación',

    view_simplified = 'Simplificado',
    view_advanced = 'Avanzado',

    warning_update = `¡Hay una nueva versión disponible! Por favor visita GitHub y actualiza a la última versión.`,
    warning_selection = 'Debes seleccionar una sola instancia de clase <b>Animation</b> antes de actualizar su miniatura',
    warning_earlyaccess = '⚠️ Recuerda presionar <b>Guardar</b> cuando termines.<br/><br/>'
        .. 'Este plugin está en desarrollo temprano. Si encuentras algún problema, reportalo en el repositorio de GitHub.',
}

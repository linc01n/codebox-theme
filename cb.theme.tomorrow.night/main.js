define([
    'ace/theme'
], function(aceTheme) {
    var themes = codebox.require("core/themes");

    themes.add({
        id: "tomorrow.night",
        title: "Tomorrow Night",

        editor: {
            'theme': aceTheme
        }
    });
});

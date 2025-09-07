-- if outside this resource, use local whatever = Require("modules/locales/shared.lua")
-- whatever.Locales("some-index-in-language-.json-file")
-- Files must be stored in "locales" folder, within the resource.
-- Instead of using Require you can also import it via the manifest.
-- The Lang variable is available globally, which tells you what the server is using.
-- print("Language: ", Lang)
-- print("Locale: ", Language.Locale("UNITTEST.locale-unit-test"))

-- Example outside community bridge resource:

-- local Language = Require('modules/locales/shared.lua')
-- print("Language: ", Lang)
-- print("Locale: ", Language.Locale("UNITTEST.locale-unit-test"))
RegisterCommand("lang", function(source, args, raw)
    print( "Oh also this works", Language.Locale("placeable_object.place_object_scroll_down"))
end, false)
Locales = Locales or {}

function _L(key, ...)
    local locale = Config.Locale or 'en'
    if Locales[locale] and Locales[locale][key] then
        if ... then
            return string.format(Locales[locale][key], ...)
        else
            return Locales[locale][key]
        end
    end
    return key
end

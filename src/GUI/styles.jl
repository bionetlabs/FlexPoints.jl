using Parameters

const BUTTON_HEIGHT = 28.0
const LAYOUT_PADDING = 2.0
const TOP_BAR_HEIGHT = BUTTON_HEIGHT + 2LAYOUT_PADDING

@with_kw struct DarkModeStyle
    background::RGBA = colorant"gray8"
end

@with_kw struct LightModeStyle
    background::RGBA = colorant"gray92"
end

struct Styles
    darkmode::DarkModeStyle
    lightmode::LightModeStyle
end

Styles() = Styles(DarkModeStyle(), LightModeStyle())
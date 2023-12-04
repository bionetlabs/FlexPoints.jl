using DataFrames

mutable struct TopBarState
    layout::GridLayout
    state::Observable{Vector{Bool}}
end

struct UIState
    figure::Figure
    topbar::TopBarState
    leftpanel::GridLayout
    centralpanel::GridLayout
    rightpanel::GridLayout
    bottombar::GridLayout
    nightmode::Observable{Bool}
    styles::Styles
end

struct AppState
    ui::UIState
    data::DataFrame
end
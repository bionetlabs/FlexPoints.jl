using DataFrames

struct UIState
    figure::Figure
    topbar::GridLayout
    leftpanel::GridLayout
    centralpanel::GridLayout
    rightpanel::GridLayout
    bottombar::GridLayout
end

struct AppState
    ui::UIState
    data::DataFrame
end
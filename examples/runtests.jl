using DataCleaner, DataFrames, PlotRecipes

fn = joinpath(tempdir(), "IF1306.csv")
df = readtable_cn(fn; nrows = 28806)

isna(@data([1, 2, NA]))
isna(([1, 2, NaN]))

fillna!(@data([NA, 1, 2, NA]))
fillna!([NaN, 1, 2, NaN])
fillna!(df)

gr()
naplot(@data([1, 2, NA])) |> gui
naplot([1, 2, 3]) |> gui
naplot(df) |> gui

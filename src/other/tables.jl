using Tables

function load!(table, ti_itr::TechnicalIndicatorIterator)
    rows = Tables.rows(table)
    # sch = Tables.schema(table)
    ind = ti_itr.indicator_instance
    for row in rows
        if !ismultiinput(ind)
            data = row[:Close]
        else
            println("ohlcv")
            opn = row[:Open]
            hig = row[:High]
            low = row[:Low]
            cls = row[:Close]
            vol = :Volume in row ? row[:Volume] : missing
            tim = :Index in row ? row[:Index] : missing
            data = OHLCV(opn, hig, low, cls, volume = vol, time = tim)
        end
        fit!(ind, data)
        println(value(ind))
    end
end

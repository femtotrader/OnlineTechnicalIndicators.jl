"""
Module defining enumerations for various candlestick pattern types.
"""

# Module for Single Candle Patterns
module SingleCandlePatternType
export SingleCandlePattern
@enum SingleCandlePattern begin
    NONE
    DOJI
    DRAGONFLY_DOJI
    GRAVESTONE_DOJI
    HAMMER
    HANGING_MAN
    SHOOTING_STAR
    INVERTED_HAMMER
    MARUBOZU_BULLISH
    MARUBOZU_BEARISH
    SPINNING_TOP
end
end # module

# Module for Two Candle Patterns
module TwoCandlePatternType
export TwoCandlePattern
@enum TwoCandlePattern begin
    NONE
    BULLISH_ENGULFING
    BEARISH_ENGULFING
    BULLISH_HARAMI
    BEARISH_HARAMI
    PIERCING_LINE
    DARK_CLOUD_COVER
    TWEEZER_TOP
    TWEEZER_BOTTOM
end
end # module

# Module for Three Candle Patterns
module ThreeCandlePatternType
export ThreeCandlePattern
@enum ThreeCandlePattern begin
    NONE
    MORNING_STAR
    EVENING_STAR
    THREE_WHITE_SOLDIERS
    THREE_BLACK_CROWS
    THREE_INSIDE_UP
    THREE_INSIDE_DOWN
end
end # module

# Module for Pattern Direction
module PatternDirection
export Direction
@enum Direction begin
    NEUTRAL
    BULLISH
    BEARISH
end
end # module

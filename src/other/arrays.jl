# Array convenience functions - delegates to Indicators module
# These are kept for backward compatibility with OnlineTechnicalIndicators.SMA(array, ...)
# Preferred usage is now: OnlineTechnicalIndicators.Indicators.SMA(array, ...)

# Import and re-export all array functions from Indicators module
using ..Indicators:
    # SISO
    SMA, EMA, SMMA, RSI, MeanDev, StdDev, ROC, WMA, KAMA, HMA,
    DPO, CoppockCurve, DEMA, TEMA, ALMA, McGinleyDynamic, ZLEMA, T3, TRIX, TSI,
    # SIMO
    BB, MACD, StochRSI, KST,
    # MISO
    AccuDist, BOP, CCI, ChaikinOsc, VWMA, VWAP, AO,
    TrueRange, ATR, ForceIndex, OBV, SOBV, EMV, MassIndex,
    CHOP, KVO, UO, NATR, MFI,
    IntradayRange, RelativeIntradayRange, ADR, ARDR,
    # Smoother
    Smoother,
    # MIMO
    Stoch, ADX, SuperTrend, VTX, DonchianChannels, KeltnerChannels,
    Aroon, ChandeKrollStop, ParabolicSAR, SFX, TTM,
    GannHiloActivator, GannSwingChart, PeakValleyDetector,
    RetracementCalculator, SupportResistanceLevel, PivotsHL,
    # Others
    STC

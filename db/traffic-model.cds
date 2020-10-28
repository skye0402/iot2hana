namespace traffic;

// Data as provided by SAP IoT service
entity TrafficData {
    key tenantId            : String(40);
    key capabilityId        : String(40);
    key sensorId            : String(40);
    key timestamp           : Double; // Unix timestamps
    gatewayTimestamp        : Double;
    measures: Composition of many {
        id                      : String(50);
        detectionOccurences     : Integer;
        trackingOccurences      : Integer;
        measuredSpeed           : Double;
        class                   : String(30);
        classStdDeviation       : Double;
        color                   : String(30);
        classAvgPropability     : Double;
        directionVerbal         : String(30);
        directionAngle          : Double; 
        detectorNumber          : Integer;
    }
};

// Holds the data from Japan meteorological agency
// https://www.data.jma.go.jp/gmd/risk/obsdl/index.php
entity meteoData {
    key timestamp               : Timestamp;
    temperature                 : Double;
    precipitation               : Double;
    noInfoPrecipitation         : Integer;
    snowfall                    : Double;
    noInfoSnowfall              : Integer;
    snowfallHeight              : Double;
    noInfoSnowfallHeight        : Integer;
    sunshineHours               : Double;
    noInfoSunshineHours         : Integer;
    windspeed                   : Double;
    winddirection               : String(8);
    airpressureLocal            : Double;
    solarradiation              : Double;
    airpressureAtSeaLevel       : Double;
    relativeHumidity            : Integer;
    vaporPressure               : Double;
    cloudiness                  : Integer;
    weather                     : Integer;
    visibility                  : Integer;
    dewPointTemperature         : Double;
};

define view TrafficDataSac as select from TrafficData{
    key TrafficData.sensorId,
    key ADD_SECONDS(TO_TIMESTAMP ('1970-01-01 00:00:00'), TrafficData.timestamp / 1000) as timestamp: Timestamp,
    measures.id, 
    measures.detectionOccurences, 
    measures.trackingOccurences, 
    measures.measuredSpeed,
    measures.class,
    measures.directionVerbal,
    measures.directionAngle,
    measures.color,
    measures.detectorNumber
};

// Show aggregrated data for EAST and WEST where speed greater than 0 and on 15min buckets
define view PredictiveDataSac as select from TrafficDataSac{
    sensorId,
    SERIES_ROUND(timestamp, 'INTERVAL 15 MINUTE', ROUND_UP) as timestamp: Timestamp,
    class as tclass: String(10),
    MAP(directionVerbal, 'N', 'X', 'S', 'X', 'SE', 'E', 'SW', 'W', 'NE', 'E', 'NW', 'W', 'E', 'E', 'W', 'W', 'X') AS direction: String(1),
    COUNT(id) as count: Integer,
    AVG(measuredSpeed)*3.6 as avgspeed: Double,
    MEDIAN(measuredSpeed)*3.6 as medianspeed: Double
}
    where measuredSpeed > 0
    group by 
        sensorId,
        SERIES_ROUND(timestamp, 'INTERVAL 15 MINUTE'),
        class,
        MAP(directionVerbal, 'N', 'X', 'S', 'X', 'SE', 'E', 'SW', 'W', 'NE', 'E', 'NW', 'W', 'E', 'E', 'W', 'W', 'X');

// Show meteorological data disggregated on 15min intervals from 1 hour
// define view meteoDataView as select from SERIES_DISAGGREGATE({
//     ('INTERVAL 1 HOUR', 'INTERVAL 15 MINUTE')
// };

// define view PredictiveDataSacTrafficWeather as select from PredictiveDataSac {
//     sensorId
// };

// CREATE COLUMN TABLE sourceseries(id INT, ts TIMESTAMP, val DECIMAL(8,2)) 
//     SERIES(SERIES KEY(id) EQUIDISTANT INCREMENT BY INTERVAL 1 YEAR MINVALUE '1999-01-01' MAXVALUE '2003-01-01'
//     PERIOD FOR SERIES (ts));

// CREATE COLUMN TABLE targetseries(id INT, ts TIMESTAMP, val DECIMAL(8,2))
//     SERIES(SERIES KEY(id) EQUIDISTANT INCREMENT BY INTERVAL 3 MONTH MINVALUE '1999-01-01' MAXVALUE '2001-01-01'
//     PERIOD FOR SERIES (ts));

// SELECT * from SERIES_DISAGGREGATE(
//  SERIES TABLE sourceseries, SERIES TABLE targetseries);

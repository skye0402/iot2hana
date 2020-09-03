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
    }
};

define view TrafficDataSac as select from TrafficData{
    key TrafficData.sensorId,
    key ADD_SECONDS(TO_TIMESTAMP ('1970-01-01 00:00:00'), TrafficData.timestamp / 1000) as timestamp: Timestamp,
    measures.id, 
    measures.detectionOccurences, 
    measures.trackingOccurences, 
    measures.measuredSpeed, 
    measures.class, 
    measures.color
};
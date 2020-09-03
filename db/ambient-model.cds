namespace ambience;

// Data as provided by SAP IoT service
entity IoTData {
    key tenantId            : String(40);
    key capabilityId        : String(40);
    key sensorId            : String(40);
    key timestamp           : Double; // Unix timestamps
    gatewayTimestamp        : Double;
    measures: Composition of many {
        CO2         : Integer;
        temperature : Double;
        humidity    : Double;
    }
};

define view iotDataSac as select from IoTData{
    key IoTData.sensorId,
    key ADD_SECONDS(TO_TIMESTAMP ('1970-01-01 00:00:00'), IoTData.timestamp / 1000) as timestamp: Timestamp,
    measures.CO2, 
    measures.temperature, 
    measures.humidity
};
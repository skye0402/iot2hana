using traffic as t from '../db/traffic-model';

service TrafficDataService {
    entity TrafficData as projection on t.TrafficData;
    entity SacTrafficData @readonly as projection on t.TrafficDataSac; 
    entity SacTrafficDataAggregated @readonly as projection on t.PredictiveDataSac;
}
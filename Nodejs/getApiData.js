const request = require('request');
var rp = require('request-promise');
var async = require('async');
var convertXml = require('xml-js');
const { Pool, Client } = require('pg');

api_key = 'xXByigc%2FKgz0txrEjTBp%2BY0PbEC5mvH8n6zlGetVEuxw89FoKIW5n4EpXB1fQZ5rTB5GPqcF7kw0d5EYP9SGNQ%3D%3D';
const pool = new Pool({
    host:'localhost', port: 5432, database:'OutDoor', user:'postgres', password: 'all1234'});
const routeInsert = 'INSERT INTO public.\"BUS_ROUTE\"\(\"Route_Id\", \"Rout_Name\", \"corpNm\", \"edStationNm\", \"stStationNm\", term, \"firstBusTm\", \"routeType\"\) VALUES($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *';
const routeStationInsert = 'INSERT INTO public.\"BUS_STATION\"\(seq, \"stationNo\", \"busRouteId\", \"gpsX\", \"gpsY\", \"posX\", \"posY\", stationid, direction, \"stationNm\", trnstnid\) VALUES($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) RETURNING *';
const routeNodeInsert = 'INSERT INTO public.\"BUS_NODE\"(\"Route_Id\", \"Seq\", \"gpsX\", \"gpsY\", \"posX\", \"posY\") VALUES ($1, $2, $3, $4, $5, $6)';

module.exports = {
    callApiData: function(type, code) {
        if(type == 'busRoute')
            return getBusRouteInfoAPI(code)
        else if(type == 'busRouteDB')
        {
            async.waterfall([
                function(callback) {
                    route_list = getBusRouteInfoDB();
                    callback(null);
                },
                function(callback, route_list) {
                    getBusRoutePathAPI
                }
            ])

            return getBusRouteInfoDB();
        }
    }
};

// API에서 버스 노선 정보 가져오기
function getBusRouteInfoAPI(code){
    request('http://ws.bus.go.kr/api/rest/busRouteInfo/getBusRouteList?serviceKey=' + api_key + '&strSrch=' + code, {xml: true}, (err, res, body) =>{
        if(err) {return console.log(err);}
        var result = JSON.parse(convertXml.xml2json(body, {compact: true, spaces: 4}));

        routeList = result.ServiceResult.msgBody.itemList;
        routeList.forEach(e => {
            values = [Number(e.busRouteId._text), e.busRouteNm._text, e.corpNm._text, e.edStationNm._text, e.stStationNm._text, Number(e.term._text), e.firstBusTm._text, Number(e.routeType._text)]
            insertQuery(routeInsert, values)
        });
    })
};

var getBusRouteInfoDB = function(){
    var route_list = [];
    pool.query('SELECT * FROM public.\"BUS_ROUTE\" LIMIT 5', '', (err, res) => { // DB에서 버스 노선 정보 가져오기
        // if(err) {return console.log(err);}
        // res.rows.forEach((d, index) => {
        //     setTimeout(async function(){
        //     console.log('read routeid = '+ d.Route_Id);
        //     await getBusRoutePathAPI(d.Route_Id);
        // }, 10000*index);

        if(err) {return console.log(err);}
        res.rows.forEach((d, index) => {
            console.log('read routeid = '+ d.Route_Id);
            route_list.push(d.route_id);
            //await getBusRoutePathAPI(d.Route_Id);
        });
    })
    return route_list;
}

// 버스 경로 가져오기
var getBusRoutePathAPI = async function(code){
    var route_id = Number(code);
    request('http://ws.bus.go.kr/api/rest/busRouteInfo/getRoutePath?serviceKey=' + api_key + '&busRouteId=' + route_id, {xml: true}, (err, res, body) =>{
        if(err) {return console.log(err);}
        var result = JSON.parse(convertXml.xml2json(body, {compact: true, spaces: 4}));
        routeList = result.ServiceResult.msgBody.itemList;
        routeList.forEach(e => {
            values = [route_id, e.no._text, e.gpsX._text, e.gpsY._text, e.posX._text, e.posY._text];
            insertQuery(routeNodeInsert, values);
        });
    });
};

function insertQuery(query, values, callback){ pool.query(query, values, (err, res) => {
    if (err) {
        console.log(err.stack)
    } else {
        console.log(values)
        console.log('insert ')
    }
})};
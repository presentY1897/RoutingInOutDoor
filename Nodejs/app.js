var GetApiData = require('./getApiData');

GetApiData.callApiData('busRouteDB');

// async.waterfall([
//   function(callback) {
//     data = GetApiData.callApiData('busRouteDB');
//     callback(null);
//   },
//   function(callback) {
//     console.log(data);
//     callback(null);
//   }
// ], function(err) {
//   console.log('error', err);
// });

for(i = 0; i < 10; i++){
  //GetApiData.callApiData('busRoute', i); // 버스 노선 정보 가져오기
};
import requests
import unrevealdata
from xml.etree import ElementTree

api_key= unrevealdata.getApi()

# Api Connect return connection
def connection(url):
    return requests.get(url)

# Get Bus Route Path return data as list
def getRoutePath(route_id):
    routePathCon = "http://ws.bus.go.kr/api/rest/busRouteInfo/getRoutePath?serviceKey=" + str(api_key) + '&busRouteId=' + route_id
    root = ElementTree.fromstring(connection(routePathCon).content)
    items = root.find("msgBody")
    result = []
    for item in items:
        data = (int(route_id), str(item.find("gpsX").text), item.find("gpsY").text, int(item.find("no").text), item.find("posX").text, item.find("posY").text)
        result.append(data)
    return result

# Get Bus Station return data as list
def getRouteStation(route_id):
    routeStationCon = "http://ws.bus.go.kr/api/rest/busRouteInfo/getStaionByRoute?serviceKey=" + str(api_key) + '&busRouteId=' + route_id
    root = ElementTree.fromstring(connection(routeStationCon).content)
    items = root.find("msgBody")
    result = []
    for item in items:
        data = (int(item.find("seq").text), 
                item.find("stationNo").text, 
                str(item.find("busRouteId").text), 
                str(item.find("station").text), 
                str(item.find("direction").text),
                str(item.find("stationNm").text),
                item.find("trnstnid").text, 
                item.find("beginTm").text, 
                item.find("busRouteNm").text, 
                int(item.find("routeType").text), 
                int(item.find("sectSpd").text), 
                int(item.find("section").text), 
                checkItemNull(item, "fullSectDist"),
                item.find("gpsX").text, 
                item.find("gpsY").text, 
                item.find("posX").text, 
                item.find("posY").text)
        result.append(data)
    return result

def checkItemNull(item, srch):
    if (item.find(srch) is None):
        return 0
    else:
        return float(item.find(srch).text)

# Get ApiData
def getApiData(api_type, args):
    if(api_type == "Path"):
        return getRoutePath(args[0])
    elif(api_type == "Station"):
        return getRouteStation(args[0])


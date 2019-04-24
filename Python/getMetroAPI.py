import requests
import unrevealdata
from xml.etree import ElementTree

api_string = 'http://swopenAPI.seoul.go.kr/api/subway/'
api_key= unrevealdata.getMetroApi()

# Api Connect return connection
def connection(url):
    return requests.get(url)

# Get Metro Route Data return list
def getRoute(route_name):
    routePathCon = api_string + str(api_key) + '/xml/subwayLine/0/5/' + route_name
    root = ElementTree.fromstring(connection(routePathCon).content)
    items = root.find("msgBody")
    result = []
    for item in items:
        data = (int(route_name), str(item.find("gpsX").text), item.find("gpsY").text, int(item.find("no").text), item.find("posX").text, item.find("posY").text)
        result.append(data)
    return result

# Get Bus Station return data as list
def getRouteStation(route_name):
    routeStationCon = api_string + str(api_key) + '/xml/stationByLine/0/1000/' + route_name
    root = ElementTree.fromstring(connection(routeStationCon).content)
    
    result = []
    for item in root.findall('row'):
        data = (int(item.find("selectedCount").text), 
                int(item.find("totalCount").text), 
                str(item.find("subwayId").text), 
                str(item.find("subwayNm").text), 
                str(item.find("statnId").text),
                str(item.find("statnNm").text),
                item.find("statnSn").text)
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
        return getRoute(args[0])
    elif(api_type == "Station"):
        return getRouteStation(args[0])


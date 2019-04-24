import getBusAPI
import getMetroAPI as mAPI
import accessDB

def insertRouteNodeData(route_id, NodeData):
    #for node in NodeData:
    #    accessDB.insertRow("OutDoor", "public.\"BUS_NODE\"", ["Route_Id", "Seq", "gpsX", "gpsY", "posX", "posY"], [route_id, node[2], node[0], node[1], node[3], node[4]])
    if(len(NodeData) != 0):
        #accessDB.insertRowBulk("OutDoor", "public.\"BUS_NODE\"", ["Route_Id",  "gpsX", "gpsY", "posX", "posY", "Seq"], NodeData) # Insert Path
        accessDB.insertBusStationBulk("OutDoor", "public.\"BUS_STATION\"", ["seq", "stationNo", "busRouteId", "stationid", "direction", "stationNm", "trnstnid", "beginTM", "busRouteNm", "routeType", "sectSpd", "section", "fullSectDist", "gpsX", "gpsY", "posX", "posY"], NodeData) # Insert Station
        print("Insert Clear " + route_id)

# data = accessDB.loadData("OutDoor", "public.\"BUS_ROUTE\"")

# for item in data:
#     route_id = str(item[0])
#     print("load route ID = " + route_id)
#     nodeData = getBusAPI.getApiData("Station", [route_id])
#     insertRouteNodeData(route_id, nodeData)

mAPI.getRouteStation('2호선')
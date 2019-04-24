import psycopg2
import unrevealdata

def execute(sql, curs, params = {}):
    curs.execute(sql, params)

def createConnString(databaseName):
    conn_string = "host = 'localhost' dbname = " + databaseName + " user = 'postgres'" + " password =" + unrevealdata.getDBPass()
    return conn_string

# general insert string
def createInsertString(tableName, COLUMNS, VALUES):
    insert_string = "INSERT INTO " + tableName + "("
    for column in COLUMNS:
        insert_string += "\"" + str(column) + "\","
    insert_string = insert_string.rstrip(",")
    insert_string += ") VALUES("
    for value in VALUES:
        insert_string += str(value) + ","
    insert_string = insert_string.rstrip(",")
    insert_string += ")"
    return insert_string

def loadData(databaseName, tableName):
    conn_string = createConnString(databaseName)
    try: 
        conn = psycopg2.connect(conn_string) 
    except: 
        print("error database connection")
    curs= conn.cursor()

    sql_string = "SELECT * FROM " + tableName
    curs.execute(sql_string)
    result = curs.fetchall()
    conn.commit()

    return result

def insertRow(databaseName, tableName, COLUMNS, VALUES):
    conn_string = createConnString(databaseName)
    try: 
        conn = psycopg2.connect(conn_string) 
    except: 
        print("error database connection")
    curs= conn.cursor()
    insert_string = createInsertString(tableName, COLUMNS, VALUES)
    curs.execute(insert_string)
    conn.commit()

def insertBusStationBulk(databaseName, tableName, COLUMNS, VALUES):
    conn_string = createConnString(databaseName)
    try: 
        conn = psycopg2.connect(conn_string) 
    except: 
        print("error database connection")
    curs= conn.cursor()

    sql = "INSERT INTO "  + tableName + "("
    for column in COLUMNS:
        sql += "\"" + str(column) + "\","
    sql = sql.rstrip(",")
    sql += """
    ) SELECT unnest(%(seq)s)::integer, 
             unnest(%(stationNo)s)::text, 
             unnest(%(busRouteId)s)::numeric, 
             unnest(%(stationid)s)::numeric, 
             unnest(%(direction)s)::text, 
             unnest(%(stationNm)s)::text, 
             unnest(%(trnstnid)s)::numeric, 
             unnest(%(beginTM)s)::text, 
             unnest(%(busRouteNm)s)::text, 
             unnest(%(routeType)s)::integer, 
             unnest(%(sectSpd)s)::integer, 
             unnest(%(section)s)::integer, 
             unnest(%(fullSectDist)s)::numeric, 
             unnest(%(gpsX)s)::text, 
             unnest(%(gpsY)s)::text, 
             unnest(%(posX)s)::text,
             unnest(%(posY)s)::text
    """
    seq = [r[0] for r in VALUES] 
    stationNo = [r[1] for r in VALUES] 
    busRouteId = [r[2] for r in VALUES] 
    stationid = [r[3] for r in VALUES] 
    direction = [r[4] for r in VALUES] 
    stationNm = [r[5] for r in VALUES] 
    trnstnid = [r[6] for r in VALUES]
    beginTM = [r[7] for r in VALUES]
    busRouteNm = [r[8] for r in VALUES]
    routeType = [r[9] for r in VALUES]
    sectSpd = [r[10] for r in VALUES]
    section = [r[11] for r in VALUES]
    fullSectDist = [r[12] for r in VALUES]
    gpsX = [r[13] for r in VALUES]
    gpsY = [r[14] for r in VALUES] 
    posX = [r[15] for r in VALUES] 
    posY = [r[16] for r in VALUES]
    curs.execute(sql, locals())
    conn.commit()
    print('for check')



def insertRowBulk(databaseName, tableName, COLUMNS, VALUES):
    conn_string = createConnString(databaseName)
    try: 
        conn = psycopg2.connect(conn_string) 
    except: 
        print("error database connection")
    curs= conn.cursor()

    sql = "INSERT INTO "  + tableName + "("
    for column in COLUMNS:
        sql += "\"" + str(column) + "\","
    sql = sql.rstrip(",")
    #sql += ") SELECT s.* FROM unnest(%s) s(id numeric, gpsX numeric, gpsY numeric, seq integer, posX numeric, posY numeric)"
    #curs.execute(sql, (VALUES,))
    sql += """
    ) SELECT unnest(%(route_id)s)::numeric, 
             unnest(%(gpsX)s)::text, 
             unnest(%(gpsY)s)::text, 
             unnest(%(posX)s)::text,
             unnest(%(posY)s)::text,
             unnest(%(seq)s)::numeric
    """
    route_id = [r[0] for r in VALUES]
    gpsX = [r[1] for r in VALUES]
    gpsY = [r[2] for r in VALUES] 
    seq = [r[3] for r in VALUES] 
    posX = [r[4] for r in VALUES] 
    posY = [r[5] for r in VALUES]
    curs.execute(sql, locals())
    conn.commit()
    print('for check')

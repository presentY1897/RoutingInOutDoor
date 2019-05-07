# Route Data

Route Data Table Schema:

## Route Table

각 노선 번호 별로 차량마다 노선 Id를 부여.

|Name|type|description|
|--|--|--|
| Route_Id | numeric | 노선 Id |
| Route_Desc_Id | numeric | 노선 번호 ex. 3412, 1호선 |
| Seq | integer | 이 노선이 해당 노선 번호에서 출발한 순서 |

## Route_St Table

노선 번호를 구성하는 정류장

|Name|type|description|
|--|--|--|
| Route_Desc_Id | numeric | Route의 Route_Desc_Id를 외래키로 참조 |
| Station_Id | numeric | 정류장 번호 |
| Seq | integer | 이 노선에서 정류장의 순서 |

## Route_Time Table

노선 번호를 구성하는 정류장

|Name|type|description|
|--|--|--|
| Route_Desc_Id | numeric | Route의 Route_Desc_Id를 외래키로 참조 |
| Times | text | 이 노선의 각 정류장별 출도착시간 일:시간:분:초를 배열로 구성 |

## 참조

[stackoverflow postgresql naming](https://stackoverflow.com/questions/2878248/postgresql-naming-conventions)
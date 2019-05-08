# Data Structure

## OutDoor Tables

### Public Transit Table

#### 1. route

노선에 관한 테이블.
시간은 초단위로 자정을 0으로 시작함.
노선의 상하행선 구분은 엄밀한 정의를 따르는 것이 아니라 회차 정류장의 이전(상행), 이후(하행)으로 구분함.

|Name|type|description|
|--|--|--|
| route_id | numeric | 노선 Id |
| route_name | text | 노선 이름 |
| route_type | integer | 노선 종류 |
| term | integer | 노선 배차 간격 (min) |
| start_time | integer | 노선 배차 시작 시간 (sec) |
| end_time | integer | 노선 배차 종료 시간 (sec) |
| p_st_ary | integer[] | 노선이 지나가는 정류장 배열(p_st의 pseudo_id를 외래키로 참조 )|
| geom | geometry | 노선 전체 형상 (srid:4326) |
| geom_up | geometry | 노선 상행선 형상 (srid:4326) |
| geom_down | geometry | 노선 하행성 형상 (srid:4326) |

#### 2. route_st

노선을 구성하는 정류장.

|Name|type|description|
|--|--|--|
| route_id(fk) | numeric | route의 route_id를 외래키로 참조 |
| station_id | numeric | 정류장 번호 |
| seq | integer | 이 노선에서 정류장의 순서 |
| section_spd | integer | 전 정류장에서 지금 정류장까지 차량 속도 (km/h) |
| dist | integer | 전 정류장에서 지금 정류장까지 거리 (meter) |

#### 3. route_station_time

노선별로 발차한 차량의 순번대로 지나간 정류장에 관한 정보.

|Name|type|description|
|--|--|--|
| route_id(fk) | numeric | route의 route_id를 외래키로 참조 |
| route_seq | integer | 해당 노선에서 발차한 차량의 순번 |
| dep_time | integer | 정류장에서 차량이 발차한 시각 (sec) |
| pseudo_id(fk) | integer | p_st 테이블의 pseudo_id를 외래키로 참조 |
| station_seq | integer | 이 노선에서 정류장의 순서 |

#### 4. route_time

노선별로 발차한 차량의 순서대로 각 정류장에 출도착한 시각.

|Name|type|description|
|--|--|--|
| route_id(fk) | numeric | route의 route_id를 외래키로 참조 |
| seq | integer | 해당 노선에서 발차한 차량의 순번 |
| time_series | integer[] | 이 노선에서 seq번째로 출발한 차량의 정류장별 출도착 시간(sec)을 차례대로 입력 |

#### 5. p_st

정류장 정보.

|Name|type|description|
|--|--|--|
| station_id | numeric | api로 가져온 데이터에서 정류장 id |
| pseudo_id | integer | 임의로 부여한 id |
| geom | geometry | 정류장의 점좌표 (srid:4326) |

#### 6. station_transfer

도보로 환승가능한 정류장 링크.
거리가 700m이하인 정류장들을 묶음.

|Name|type|description|
|--|--|--|
| f_id(fk) | integer | p_st의 pseudo_id를 외래키로 참조 |
| e_id(fk) | integer | p_st의 pseudo_id를 외래키로 참조 |
| dist | double precision | 두 정류장의 거리 |

### Car Table

ITS 노드 링크 데이터에서 가져온 도로망

#### 1. its_node

도로망의 노드(node) 정보.

|Name|type|description|
|--|--|--|
| gid | integer | 도로망 노드 임의의 id |
| node_id | character varying(10) | ITS 데이터에서 지정한 id |
| node_name | character varying(44) | 노드 이름 |
| geom | geometry | 노드 형상 정보 (srid:4326) |

#### 2. its_link

도로망의 도로(link) 정보.

|Name|type|description|
|--|--|--|
| gid | integer | 도로망 링크 임의의 id |
| link_id | character varying(10) | ITS 데이터에서 지정한 id |
| f_node(fk) | character varying(10) | ITS 데이터에서 시작 노드 id |
| t_node(fk) | character varying(10) | ITS 데이터에서 도착 노드 id |
| road_name | character varying(44) | 도로 이름 |
| source(fk) | integer | its_node에서 시작한 노드의 id |
| target(fk) | integer | its_node에서 도착한 노드의 id |
| length | double precision | 도로 길이(meter) |
| geom | geometry | 도로 형상 정보 (srid:4326) |

## InDoor Tables

### Building Table

#### 1. building

건물 정보.

|Name|type|description|
|--|--|--|
| building_id | integer | 건물 id |
| building_name | text | 건물 이름 |

#### 2. building_node

건물의 노드(node) 정보.
건물 안을 구성하는 노드 데이터.

|Name|type|description|
|--|--|--|
| building_id(fk) | integer | building 테이블의 building_id를 외래키로 참조 |
| node_id | integer | 노드의 id |
| node_name | text | 노드의 이름 |
| node_type | integer | 노드의 종류 |
| floor | double precision | 노드가 위치한 층 |
| exterior | boolean | 외부 출입문 여부 (참:외부와 연결/ 거짓:실내) |
| geom | geometry | 노드의 형상정보 (srid:4326) |

#### 3. building_link

건물 안의 링크 정보.

|Name|type|description|
|--|--|--|
| building_id(fk) | integer | building 테이블의 building_id를 외래키로 참조 |
| link_id | integer | 링크의 id |
| link_type | integer | 링크 종류 |
| floor | double precision | 링크가 위치한 층 |
| source(fk) | integer | 링크의 시작 노드, building_node의 node_id를 외래키로 참조 |
| target(fk) | integer | 링크의 도착 노드, building_node의 node_id를 외래키로 참조 |
| dist | double precision | 링크의 거리(meter) |
| geom | geometry | 링크의 형상정보 (srid:4326) |

## 참조

[stackoverflow postgresql naming](https://stackoverflow.com/questions/2878248/postgresql-naming-conventions)
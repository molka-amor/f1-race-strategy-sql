CREATE TABLE circuits (
    circuitId    INTEGER PRIMARY KEY,
    circuitRef   VARCHAR(50) NOT NULL,
    name         VARCHAR(100) NOT NULL,
    location     VARCHAR(100),
    country      VARCHAR(50),
    lat          DECIMAL(9,6),
    lng          DECIMAL(9,6),
    alt          INTEGER,
    url          VARCHAR(255)
);

CREATE TABLE drivers (
    driverId     INTEGER PRIMARY KEY,
    driverRef    VARCHAR(50) NOT NULL,
    number       INTEGER,
    code         VARCHAR(3),
    forename     VARCHAR(50) NOT NULL,
    surname      VARCHAR(50) NOT NULL,
    dob          DATE,
    nationality  VARCHAR(50),
    url          VARCHAR(255)
);

CREATE TABLE constructors (
    constructorId    INTEGER PRIMARY KEY,
    constructorRef   VARCHAR(50) NOT NULL,
    name             VARCHAR(100) NOT NULL,
    nationality      VARCHAR(50),
    url              VARCHAR(255)
);

CREATE TABLE status (
    statusId    INTEGER PRIMARY KEY,
    status      VARCHAR(50) NOT NULL
);

CREATE TABLE races (
    raceId       INTEGER PRIMARY KEY,
    year         INTEGER NOT NULL,
    round        INTEGER NOT NULL,
    circuitId    INTEGER NOT NULL,
    name         VARCHAR(100) NOT NULL,
    date         DATE NOT NULL,
    time         TIME,
    url          VARCHAR(255),
    fp1_date     DATE,  fp1_time  TIME,
    fp2_date     DATE,  fp2_time  TIME,
    fp3_date     DATE,  fp3_time  TIME,
    quali_date   DATE,  quali_time TIME,
    sprint_date  DATE,  sprint_time TIME,

    FOREIGN KEY (circuitId) REFERENCES circuits(circuitId)
);

CREATE TABLE results (
    resultId         INTEGER PRIMARY KEY,
    raceId           INTEGER NOT NULL,
    driverId         INTEGER NOT NULL,
    constructorId    INTEGER NOT NULL,
    number           INTEGER,
    grid             INTEGER NOT NULL,
    position         INTEGER,
    positionText     VARCHAR(10),
    positionOrder    INTEGER NOT NULL,
    points           DECIMAL(5,2) NOT NULL,
    laps             INTEGER NOT NULL,
    time             VARCHAR(20),
    milliseconds     INTEGER,
    fastestLap       INTEGER,
    rank             INTEGER,
    fastestLapTime   VARCHAR(20),
    fastestLapSpeed  DECIMAL(6,3),
    statusId         INTEGER NOT NULL,

    FOREIGN KEY (raceId)        REFERENCES races(raceId),
    FOREIGN KEY (driverId)      REFERENCES drivers(driverId),
    FOREIGN KEY (constructorId) REFERENCES constructors(constructorId),
    FOREIGN KEY (statusId)      REFERENCES status(statusId)
);

CREATE TABLE qualifying (
    qualifyId       INTEGER PRIMARY KEY,
    raceId          INTEGER NOT NULL,
    driverId        INTEGER NOT NULL,
    constructorId   INTEGER NOT NULL,
    number          INTEGER,
    position        INTEGER,
    q1              VARCHAR(20),
    q2              VARCHAR(20),
    q3              VARCHAR(20),

    FOREIGN KEY (raceId)        REFERENCES races(raceId),
    FOREIGN KEY (driverId)      REFERENCES drivers(driverId),
    FOREIGN KEY (constructorId) REFERENCES constructors(constructorId)
);

CREATE TABLE pit_stops (
    raceId        INTEGER NOT NULL,
    driverId      INTEGER NOT NULL,
    stop          INTEGER NOT NULL,
    lap           INTEGER NOT NULL,
    time          TIME,
    duration      VARCHAR(20),
    milliseconds  INTEGER,

    PRIMARY KEY (raceId, driverId, stop),
    FOREIGN KEY (raceId)   REFERENCES races(raceId),
    FOREIGN KEY (driverId) REFERENCES drivers(driverId)
);

CREATE TABLE lap_times (
    raceId        INTEGER NOT NULL,
    driverId      INTEGER NOT NULL,
    lap           INTEGER NOT NULL,
    position      INTEGER,
    time          VARCHAR(20),
    milliseconds  INTEGER,

    PRIMARY KEY (raceId, driverId, lap),
    FOREIGN KEY (raceId)   REFERENCES races(raceId),
    FOREIGN KEY (driverId) REFERENCES drivers(driverId)
);
-- This file contains all code required to create & seed database tables.

\c museum;

DROP TABLE IF EXISTS rating_interaction, request_interaction, exhibition, department, floor, request, rating;

CREATE TABLE department (
    department_id SMALLINT GENERATED ALWAYS AS IDENTITY,
    department_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (department_id)
);

CREATE TABLE floor (
    floor_id SMALLINT,
    floor_name VARCHAR(100) NOT NULL,
    PRIMARY KEY (floor_id)
);

CREATE TABLE exhibition (
    exhibition_id SMALLINT,
    exhibition_name VARCHAR(100) NOT NULL,
    exhibition_description TEXT NOT NULL,
    department_id SMALLINT NOT NULL,
    floor_id SMALLINT NOT NULL,
    exhibition_start_date DATE NOT NULL,
    public_id TEXT NOT NULL,
    PRIMARY KEY (exhibition_id),
    FOREIGN KEY (department_id) REFERENCES department(department_id),
    FOREIGN KEY (floor_id) REFERENCES floor(floor_id),
    CONSTRAINT description_must_be_more_than_one_char CHECK (
        LENGTH(exhibition_description) > 1
    )
);

CREATE TABLE request (
    request_id SMALLINT,
    request_value SMALLINT NOT NULL,
    request_description VARCHAR(100) NOT NULL,
    PRIMARY KEY (request_id),
    CONSTRAINT description_must_be_more_than_one_char CHECK (
        LENGTH(request_description) > 1
    )
);

CREATE TABLE rating (
    rating_id SMALLINT,
    rating_value SMALLINT NOT NULL,
    rating_description VARCHAR(100) NOT NULL,
    PRIMARY KEY (rating_id),
    CONSTRAINT description_must_be_more_than_one_char CHECK (
        LENGTH(rating_description) > 1
    )
);

CREATE TABLE request_interaction (
    request_interaction_id BIGINT GENERATED ALWAYS AS IDENTITY,
    exhibition_id SMALLINT NOT NULL,
    request_id SMALLINT NOT NULL,
    event_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (request_interaction_id),
    FOREIGN KEY (exhibition_id) REFERENCES exhibition(exhibition_id),
    FOREIGN KEY (request_id) REFERENCES request(request_id),
    CONSTRAINT no_future_dates CHECK (
        event_at <= CURRENT_TIMESTAMP
    )
);

CREATE TABLE rating_interaction (
    rating_interaction_id BIGINT GENERATED ALWAYS AS IDENTITY,
    exhibition_id SMALLINT NOT NULL,
    rating_id SMALLINT NOT NULL,
    event_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (rating_interaction_id),
    FOREIGN KEY (exhibition_id) REFERENCES exhibition(exhibition_id),
    FOREIGN KEY (rating_id) REFERENCES rating(rating_id),
    CONSTRAINT no_future_dates CHECK (
        event_at <= CURRENT_TIMESTAMP
    )
);

INSERT INTO rating (rating_id, rating_value, rating_description) VALUES 
(0, 0, 'Terrible'),
(1, 1, 'Bad'),
(2, 2, 'Neutral'),
(3, 3, 'Good'),
(4, 4, 'Amazing');

INSERT INTO request (request_id, request_value, request_description) VALUES 
(0, 0, 'Assistance'),
(1, 1, 'Emergency');

INSERT INTO floor (floor_id, floor_name) VALUES 
(-1, 'Vault'),
(0, 'Ground'),
(1, 'First'),
(2, 'Second'),
(3, 'Third');

INSERT INTO department (department_name) VALUES 
('Entomology'),
('Geology'),
('Paleontology'),
('Zoology'),
('Ecology');

INSERT INTO exhibition (exhibition_id, exhibition_name, exhibition_description, 
department_id, floor_id, exhibition_start_date, public_id) VALUES
(0, 'Measureless to Man', 'An immersive 3D experience: delve deep into a previously-inaccessible cave system.',
2, 1, '2021-08-23', 'EXH_00'),
(1, 'Adaptation', 'How insect evolution has kept pace with an industrialised world.',
1, -1, '2019-07-01', 'EXH_01'),
(2, 'The Crenshaw Collection', 'An exhibition of 18th Century watercolours, mostly focused on South American wildlife.',
4, 2, '2021-03-03', 'EXH_02'),
(3, 'Cetacean Sensations', 'Whales: from ancient myth to critically endangered.',
4, 1, '2019-07-01', 'EXH_03'),
(4, 'Our Polluted World', 'A hard-hitting exploration of humanity''s impact on the environment.',
5, 3, '2021-05-12', 'EXH_04'),
(5, 'Thunder Lizards', 'How new research is making scientists rethink what dinosaurs really looked like.',
3, 1, '2023-02-01', 'EXH_05');
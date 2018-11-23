-- Tests for WITHOUT OVERLAPS.

--
-- test input parser
--

-- PK with no columns just WITHOUT OVERLAPS:

CREATE TABLE without_overlaps_test (
	valid_at tsrange,
	CONSTRAINT without_overlaps_pk PRIMARY KEY (WITHOUT OVERLAPS valid_at)
);

-- PK with a range column that isn't there:

CREATE TABLE without_overlaps_test (
	id INTEGER,
	CONSTRAINT without_overlaps_pk PRIMARY KEY (id, WITHOUT OVERLAPS valid_at)
);

-- PK with a PERIOD that isn't there:
-- TODO

-- PK with a non-range column:

CREATE TABLE without_overlaps_test (
	id INTEGER,
	valid_at TEXT,
	CONSTRAINT without_overlaps_pk PRIMARY KEY (id, WITHOUT OVERLAPS valid_at)
);

-- PK with one column plus a range:

CREATE TABLE without_overlaps_test (
	-- Since we can't depend on having btree_gist here,
	-- use an int4range instead of an int.
	-- (The rangetypes regression test uses the same trick.)
	id int4range,
	valid_at tsrange,
	CONSTRAINT without_overlaps_pk PRIMARY KEY (id, WITHOUT OVERLAPS valid_at)
);

-- PK with two columns plus a range:
CREATE TABLE without_overlaps_test2 (
	id1 int4range,
	id2 int4range,
	valid_at tsrange,
	CONSTRAINT without_overlaps2_pk PRIMARY KEY (id1, id2, WITHOUT OVERLAPS valid_at)
);
DROP TABLE without_overlaps_test2;


-- PK with one column plus a PERIOD:
-- TODO

-- PK with two columns plus a PERIOD:
-- TODO

-- PK with a custom range type:
CREATE TYPE textrange AS range (subtype=text, collation="C");
CREATE TABLE without_overlaps_test2 (
	id int4range,
	valid_at textrange,
	CONSTRAINT without_overlaps2_pk PRIMARY KEY (id, WITHOUT OVERLAPS valid_at)
);
ALTER TABLE without_overlaps_test2 DROP CONSTRAINT without_overlaps2_pk;
DROP TABLE without_overlaps_test2;
DROP TYPE textrange;

DROP TABLE without_overlaps_test;
CREATE TABLE without_overlaps_test (
	id int4range,
	valid_at tsrange
);
ALTER TABLE without_overlaps_test
	ADD CONSTRAINT without_overlaps_pk
	PRIMARY KEY (id, WITHOUT OVERLAPS valid_at);

--
-- test pg_get_constraintdef
--

SELECT pg_get_constraintdef(oid) FROM pg_constraint WHERE conname = 'without_overlaps_pk';

--
-- test PK inserts
--

-- okay:
INSERT INTO without_overlaps_test VALUES ('[1,1]', tsrange('2018-01-02', '2018-02-03'));
INSERT INTO without_overlaps_test VALUES ('[1,1]', tsrange('2018-03-03', '2018-04-04'));
INSERT INTO without_overlaps_test VALUES ('[2,2]', tsrange('2018-01-01', '2018-01-05'));
INSERT INTO without_overlaps_test VALUES ('[3,3]', tsrange('2018-01-01', NULL));

-- should fail:
INSERT INTO without_overlaps_test VALUES ('[1,1]', tsrange('2018-01-01', '2018-01-05'));
INSERT INTO without_overlaps_test VALUES (NULL, tsrange('2018-01-01', '2018-01-05'));
INSERT INTO without_overlaps_test VALUES ('[3,3]', NULL);



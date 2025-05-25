-- DDL Test for kleague Sample Database
-- Version 1.0

USE kleague;

DESCRIBE PLAYER;
DESCRIBE TEAM;
DESCRIBE STADIUM;
DESCRIBE SCHEDULE;

-------------------------------------------
-- 3. CREATE TABLE
-------------------------------------------

-- CREATE TABLE 문은 kleagueDB-SchemaData.sql 화일 참조

------------------------------

-- CTAS와 CREATE TABLE 문의 차이

CREATE TABLE 	TEMP AS		/* Schema navigator에서 테이블 생성됨을 확인 */
SELECT	*
FROM	SCHEDULE
WHERE	HOMETEAM_ID = 'K08' OR AWAYTEAM_ID = 'K08';

DESCRIBE	SCHEDULE;
DESCRIBE	TEMP;			/* PK, FK, UNIQUE, CHECK 제약 조건은 없어짐 */

SELECT	* FROM SCHEDULE;
SELECT	* FROM TEMP;

DROP TABLE 	TEMP;			/* Schema navigator에서 테이블 삭제됨을 확인 */


-------------------------------------------
-- 4. DROP TABLE
-------------------------------------------

-- MySQL에서 DROP TABLE의 RESTRICT|CASCADE는 아무 역할을 안함. 
-- 다른 DBMS으로의 포팅을 위해서만 사용됨.
-- MySQL에서의 DROP TABLE은 RESTRICT|CASCADE와는 관계없이, 스키마에서 FK의 유무에 의해서만 실행이 허용/거부됨.
-- 즉, 자식 테이블이 한 개라도 있으면, 부모 테이블에 대한 삭제가 거부됨.

-- kleague DB를 초기화(다시 설치)한 후, 아래 질의를 실행

DROP TABLE	STADIUM;		/* 에러, 자식 테이블(TEAM, SCHEDULE)이 있음. */
DROP TABLE	TEAM;			/* 에러, 자식 테이블(PLAYER, SCHEDULE)이 있음. */

DROP TABLE 	PLAYER;
DROP TABLE	TEAM;			/* 에러, 아직도 자식 테이블(SCHEDULE)이 남아 있음. */

DROP TABLE	SCHEDULE;
DROP TABLE	TEAM;

DROP TABLE	STADIUM;


-------------------------------------------
-- 5. ALTER TABLE
-------------------------------------------

-- kleague DB를 초기화한 후, 아래 질의를 실행

DESCRIBE PLAYER;

ALTER TABLE		PLAYER
ADD	COLUMN		ADDRESS VARCHAR(80);

DESCRIBE PLAYER;

ALTER TABLE 	PLAYER
DROP COLUMN		ADDRESS;

DESCRIBE PLAYER;


-------------------------------------------
-- 6. RENAME TABLE
-------------------------------------------

DESCRIBE STADIUM;
RENAME TABLE 	STADIUM TO 경기장;
DESCRIBE STADIUM;	/* 에러: STADIUM 테이블이 존재하지 않음 */
DESCRIBE 경기장;

RENAME TABLE 	TEAM TO 팀,
				SCHEDULE TO 경기,
                PLAYER TO 선수;


-------------------------------------------
-- 7. TRUNCATE TABLE
-------------------------------------------

-- kleague DB를 초기화한 후, 아래 질의를 실행

SELECT	* FROM PLAYER;
TRUNCATE TABLE 	PLAYER;	/* 로그에 기록을 안 남김 (복구 불가). 아래 메세지에서 '0 row(s) returned' */
SELECT	* FROM PLAYER;

------------------------------
-- kleague DB를 초기화한 후, 아래 질의를 실행

SELECT	* FROM PLAYER;
DROP TABLE 	PLAYER;		/* 테이블도 삭제함. 로그에 기록을 안 남김 (복구 불가). 아래 메세지에서 '0 row(s) returned' */
SELECT	* FROM PLAYER;	/* 에러: 테이블 PLAYER가 존재하지 않음 */

------------------------------
/* Note 1 : TRUNCATE TABLE 문은 DROP TABLE과 동일한 실행 조건을 가짐. */
/* 즉, 자식 테이블이 있으면, 실행이 거부됨. */

-- kleague DB를 초기화한 후, 아래 질의를 실행

TRUNCATE TABLE	TEAM;			/* 에러, 자식 테이블(PLAYER, SCHEDULE)이 있음. */

DROP TABLE 	PLAYER;
TRUNCATE TABLE	TEAM;			/* 에러, 아직도 자식 테이블(SCHEDULE)이 남아 있음. */

DROP TABLE 	SCHEDULE;
TRUNCATE TABLE	TEAM;


------------------------------
/* Note 2 : DML 명령어는 safe_update mode로 동작하면, WHERE 절에서 PK로 조건을 주지 않으면 에러가 발생함. */

-- kleague DB를 초기화한 후, 아래 질의를 실행

SELECT	* FROM PLAYER;
DELETE FROM		PLAYER;	/* 에러 */

SET sql_safe_updates=0;	/* safe_update mode 비활성화 */

SELECT	* FROM PLAYER;
DELETE FROM 	PLAYER;	/* 로그에 기록을 남김 (복구 가능). 아래 메세지에서 '480 row(s) affected' */
SELECT	* FROM PLAYER;

SET sql_safe_updates=1;	/* safe_update mode 활성화 */


-------------------------------------------
-- 8. INFORMATION_SCHEMA 테이블들 (Catalogue)
-------------------------------------------

-- kleague DB를 초기화한 후, 아래 질의를 실행

use INFORMATION_SCHEMA;

SELECT 	*
FROM 	INFORMATION_SCHEMA.SCHEMATA;

------------------------------

SELECT 	*
FROM 	INFORMATION_SCHEMA.TABLES;

SELECT 	*
FROM 	INFORMATION_SCHEMA.TABLES
WHERE	TABLE_SCHEMA = 'kleague';

------------------------------

SELECT 	*
FROM 	INFORMATION_SCHEMA.COLUMNS;

SELECT 	*
FROM 	INFORMATION_SCHEMA.COLUMNS
WHERE	TABLE_SCHEMA = 'kleague' AND TABLE_NAME = 'schedule';

------------------------------

SELECT 	CONSTRAINT_SCHEMA, CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, 
		REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM 	INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE	CONSTRAINT_SCHEMA = 'kleague' AND TABLE_NAME = 'schedule'
ORDER   BY CONSTRAINT_NAME DESC;

SELECT 	CONSTRAINT_SCHEMA, CONSTRAINT_NAME, DELETE_RULE, UPDATE_RULE, 
		TABLE_NAME, REFERENCED_TABLE_NAME
FROM 	INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
WHERE	CONSTRAINT_SCHEMA = 'kleague' AND TABLE_NAME = 'schedule';

------------------------------

SELECT 	SPECIFIC_NAME, SQL_MODE	
FROM 	INFORMATION_SCHEMA.ROUTINES;

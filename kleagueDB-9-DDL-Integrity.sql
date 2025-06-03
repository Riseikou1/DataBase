-- DDL Test for kleague Sample Database
-- Version 1.0

USE kleague;

DESCRIBE PLAYER;
DESCRIBE TEAM;
DESCRIBE STADIUM;
DESCRIBE SCHEDULE;

-------------------------------------------
-- 1. PK Constraint
-------------------------------------------

-- Q: 키 값의 수정

SELECT 	* FROM TEAM;

UPDATE 	TEAM
SET		TEAM_ID = '***'
WHERE	TEAM_ID = 'K02';

SELECT 	* FROM TEAM;

-- Q: PK constraint (Entity integrity constraint)

/* PK 제약조건 위반으로 실행이 거부됨 : PK는 NOT NULL */
INSERT INTO 	TEAM (TEAM_ID, REGION_NAME, TEAM_NAME, STADIUM_ID) 
VALUES 			(NULL,'LA','LA 다저스','LAD');

/* PK 제약조건 위반으로 실행이 거부됨 : 존재하는 PK 값 */
INSERT INTO		TEAM (TEAM_ID, REGION_NAME, TEAM_NAME, STADIUM_ID) 
VALUES 			('K01','LA','LA 다저스','LAD');

SELECT 	* FROM TEAM;


-------------------------------------------
-- 2. FK Constraint
-------------------------------------------

-------------------------------------------
-- 2.1 자식 테이블에 FK 삽입/수정
-------------------------------------------

-- Q: 존재하지 않는 FK 값'LAD'을 자식 테이블에 insert/update할 때

SELECT 	* FROM TEAM;
SELECT 	* FROM STADIUM;

/* FK 제약조건 위반으로 실행이 거부됨 : LAD라는 경기장이 없음. */
INSERT INTO		TEAM (TEAM_ID, REGION_NAME, TEAM_NAME, STADIUM_ID) 
VALUES			('K20','LA','LA 다저스','LAD');

/* FK 제약조건 위반으로 실행이 거부됨 : LAD라는 경기장이 없음. */
UPDATE 	TEAM
SET		STADIUM_ID = 'LAD'
WHERE	TEAM_ID = 'K03';


-------------------------------------------
-- 2.2 부모 테이블에서 PK 삭제 (자식 테이블의 FK 옵션이 RESTRICT인 경우)
-------------------------------------------

-- kleague DB를 초기화한 후, 아래 질의를 실행

-- Q: 부모 테이블에서 PK 값을 delete할 때, 자식 테이블의 FK 옵션이 RESTRICT 경우는 부모 테이블에서 delete가 거부됨.

SELECT 	* FROM STADIUM;			/* 부모 테이블 확인 */
SELECT 	* FROM TEAM;			/* 자식 테이블인 TEAM에서 K09 팀의 전용구장이 B05임 */

/* 에러: FK 제약조건 위반으로 실행이 거부됨 */
DELETE FROM 	STADIUM
WHERE 			STADIUM_ID = 'B05';

-- 이유 1: 경기장 B05를 참조하는 팀이 있음. (FK인 TEAM.STADIUM_ID의 참조 무결성 옵션이 RESTRICT)
-- 이유 2: 경기장 B05를 참조하는 경기들이 있음. (FK인 SCHEDULE.STADIUM_ID의 참조 무결성 옵션이 RESTRICT)

-- TEAM 테이블에서 STADIUM_ID의 참조 무결성 옵션을 CASCADE로 변경함.

ALTER TABLE 		TEAM
DROP FOREIGN KEY 	FK_TEAM_STADIUM;

ALTER TABLE 	TEAM
ADD CONSTRAINT	FK_TEAM_STADIUM_NEW	FOREIGN KEY (STADIUM_ID) REFERENCES STADIUM(STADIUM_ID)
											ON DELETE CASCADE
											ON UPDATE CASCADE;

-- SCHEDULE 테이블에서 STADIUM_ID의 참조 무결성 옵션을 CASCADE로 변경함.

ALTER TABLE 		SCHEDULE
DROP FOREIGN KEY 	FK_SCHEDULE_STADIUM;

ALTER TABLE 	SCHEDULE
ADD CONSTRAINT 	FK_SCHEDULE_STADIUM_NEW  FOREIGN KEY (STADIUM_ID) REFERENCES STADIUM(STADIUM_ID)
											ON DELETE CASCADE
											ON UPDATE CASCADE;


-------------------------------------------
-- 2.3 부모 테이블에서 PK 삭제 (자식 테이블의 FK 옵션이 RESTRICT인 경우)
-------------------------------------------

/* 에러: FK 제약조건 위반으로 실행이 또 거부됨 */
DELETE	FROM STADIUM
WHERE 	STADIUM_ID = 'B05';

-- 이유: (경기장 B05를 참조하는) K08 팀을 참조하는 경기들이 있음. 
--      (FK인 SCHEDULE.HOMETEAM_ID와 SCHEDULE.AWAYTEAM_ID의 참조 무결성 옵션이 RESTRICT)

-- SCHEDULE 테이블에서 HOMETEAM_ID와 AWAYTEAM_ID의 참조 무결성 옵션을 CASCADE로 변경함.

ALTER TABLE 		SCHEDULE
DROP FOREIGN KEY 	FK_SCHEDULE_HOMETEAM,
DROP FOREIGN KEY 	FK_SCHEDULE_AWAYTEAM;

ALTER TABLE 	SCHEDULE
ADD CONSTRAINT 	FK_SCHEDULE_HOMETEAM_NEW FOREIGN KEY (HOMETEAM_ID) REFERENCES TEAM(TEAM_ID)
												ON DELETE CASCADE
												ON UPDATE CASCADE,
ADD CONSTRAINT 	FK_SCHEDULE_AWAYTEAM_NEW FOREIGN KEY (AWAYTEAM_ID) REFERENCES TEAM(TEAM_ID)
												ON DELETE CASCADE
												ON UPDATE CASCADE;

------------------------------

-- 삭제 전, 각 테이블의 투플 수를 확인

SELECT 	COUNT(*) FROM STADIUM;		/* 20개 */	
SELECT 	COUNT(*) FROM TEAM;			/* 15개 */
SELECT 	COUNT(*) FROM SCHEDULE;		/* 179개 */
SELECT 	COUNT(*) FROM PLAYER;		/* 480명 */

SELECT	COUNT(*) FROM SCHEDULE WHERE STADIUM_ID = 'B05';	/* 서울월드컵경기장, 19개 */
SELECT	COUNT(*) FROM SCHEDULE WHERE HOMETEAM_ID = 'K09' OR AWAYTEAM_ID = 'K09';	/* 서울 FC의 경기, 36개 */
SELECT	COUNT(*) FROM PLAYER WHERE TEAM_ID = 'K09';		/* 서울 FC의 선수, 49명 */

SELECT 	* FROM STADIUM WHERE STADIUM_ID='B05';
SELECT 	* FROM TEAM WHERE STADIUM_ID='B05';				/* 경기장 B05를 전용구장으로 사용하는 팀은 K09 */
SELECT 	* FROM SCHEDULE WHERE STADIUM_ID='B05';			/* 경기장 B05에서 진행된 경기가 19 경기 */
SELECT	* FROM PLAYER WHERE TEAM_ID='K09';				/* 팀 K09의 소속 선수는 49명 */
SELECT 	* FROM SCHEDULE WHERE HOMETEAM_ID='K09';		/* 팀 K09가 홈팀으로 참여한 경기는 19 경기 */
SELECT 	* FROM SCHEDULE WHERE AWAYTEAM_ID='K09';		/* 팀 K09가 어웨이팀으로 참여한 경기는 17 경기 */

-- 수정된 FK 제약조건에 따라, 드디어 TEAM, PLAYER, SCHEDULE에서 연속적으로 삭제가 실행됨.

DELETE FROM 	STADIUM
WHERE 			STADIUM_ID = 'B05';

-- 삭제 후, 각 테이블의 투플 수를 확인

SELECT 	COUNT(*) FROM STADIUM;		/* 19개 (20 - 19 = 1개 삭제됨)*/
SELECT 	COUNT(*) FROM TEAM;			/* 14개 (15 - 14 = 1개 삭제됨) */
SELECT 	COUNT(*) FROM SCHEDULE;		/* 143개 (179 - 143 = 36개 삭제됨) */
SELECT 	COUNT(*) FROM PLAYER;		/* 480명 (삭제된 선수 없음) */

SELECT	COUNT(*) FROM PLAYER WHERE TEAM_ID IS NULL;				/* 팀 K09의 소속 선수는 49명 */


-------------------------------------------
-- 2.4 부모 테이블에서 PK 수정 (자식 테이블의 FK 옵션이 CASCADE인 경우)
-------------------------------------------

-- Q6: 부모 테이블에서 PK 값을 수정할 때, CASCADE 옵션에서는 자식 테이블에도 update가 연속적으로 실행됨. 그러나 손자로는 전파되지 않음.

SELECT 	* FROM STADIUM WHERE STADIUM_ID = 'A02';
SELECT 	* FROM TEAM WHERE STADIUM_ID = 'A02';		/* A02 경기장을 전굥구장으로 사용하는 팀은 K12 */

UPDATE	STADIUM
SET		STADIUM_ID = '###'
WHERE	STADIUM_ID = 'A02';

SELECT 	* FROM STADIUM WHERE STADIUM_ID = '###';
SELECT 	* FROM TEAM WHERE STADIUM_ID = '###';


-------------------------------------------
-- 참고: 스키마의 모든 PK와 FK 정보를 확인
-------------------------------------------

-- 스키마의 모든 PK와 FK를 확인

SELECT 	CONSTRAINT_SCHEMA, CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, 
		REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM 	INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE	CONSTRAINT_SCHEMA = 'kleague'
ORDER   BY CONSTRAINT_NAME DESC;

-- FK의 Referential option 확인

SELECT 	CONSTRAINT_SCHEMA, CONSTRAINT_NAME, DELETE_RULE, UPDATE_RULE, 
		TABLE_NAME, REFERENCED_TABLE_NAME
FROM 	INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
WHERE	CONSTRAINT_SCHEMA = 'kleague';


-------------------------------------------
-- 3. DROP TABLE에서의 RESTRICT/CASCADE 의미
-------------------------------------------

-- kleague DB를 초기화한 후, 아래 질의를 실행

DROP TABLE	TEAM;			/* 에러, 자식 테이블(PLAYER)이 있음. */

-- 이유: TEAM을 참조하는 자식 테이블(SCHEDULE)이 있음. (FK인 SCHEDULE.HOMETEAM_ID와 SCHEDULE.AWAYTEAM_ID의 참조 무결성 옵션이 RESTRICT)

-- SCHEDULE 테이블에서 HOMETEAM_ID와 AWAYTEAM_ID의 참조 무결성 옵션을 CASCADE로 변경함.

ALTER TABLE 		SCHEDULE
DROP FOREIGN KEY 	FK_SCHEDULE_HOMETEAM,
DROP FOREIGN KEY 	FK_SCHEDULE_AWAYTEAM;

ALTER TABLE 	SCHEDULE
ADD CONSTRAINT 	FK_SCHEDULE_HOMETEAM_NEW FOREIGN KEY (HOMETEAM_ID) REFERENCES TEAM(TEAM_ID)
												ON DELETE CASCADE
												ON UPDATE CASCADE,
ADD CONSTRAINT 	FK_SCHEDULE_AWAYTEAM_NEW FOREIGN KEY (AWAYTEAM_ID) REFERENCES TEAM(TEAM_ID)
												ON DELETE CASCADE
												ON UPDATE CASCADE;

------------------------------

DROP TABLE	TEAM; 			/* 에러 */
DROP TABLE	TEAM CASCADE;	/* 에러 */

/* 표준 sQL에서는 위 명렬문이 정상 실행됨. 그러나 MySQL에서는 에러 */
/* MySQL에서의 DROP TABLE 명령문은 자식 테이블에서 참조하는 투플의 존재 여부에 관계없이, 자식 테이블의 존재 여부에 의해서만 실행이 허용/거부됨. */
/* 즉 자식 테이블이 하나라도 있으면 실행이 거부됨. */

------------------------------

/* TEAM을 삭제하려면, 자식 테이블을 먼저 삭제하거나, 자식 테이블에서 FK를 삭제해야 함. */
/* 아래는 자식 테이블들을 먼저 삭제한 후, TEAM 데이블을 삭제하는 것임. */

DROP TABLE	SCHEDULE;
DROP TABLE	PLAYER;
DROP TABLE	TEAM; 			/* 실행됨 */


-------------------------------------------
-- CASE STUDY 1 : K-League DB
-------------------------------------------

-- 스키마에서 FK의 ON DELETE 옵션을 그림 처럼 수정함

USE kleague;

SELECT	*	FROM	STADIUM;		/* 20개 */
SELECT	*	FROM	TEAM;			/* 15개 */
SELECT	*	FROM	SCHEDULE;		/* 179개 */
SELECT	*	FROM	PLAYER;			/* 480개 */

DELETE
FROM	TEAM
WHERE	TEAM_ID = 'K02';

SELECT	*	FROM	STADIUM;		/* 20개 */
SELECT	*	FROM	TEAM;			/* 14개 (1개 삭재) */
SELECT	*	FROM	SCHEDULE;		/* 143개 (36개 삭재) */
SELECT	*	FROM	PLAYER;			/* 480개 */

-- kleague 초기화한 후, 아래 질의를 실행

SELECT	*	FROM	STADIUM;		/* 20개 */
SELECT	*	FROM	TEAM;			/* 15개 */
SELECT	*	FROM	SCHEDULE;		/* 179개 */
SELECT	*	FROM	PLAYER;			/* 480개 */

DELETE
FROM	STADIUM
WHERE	STADIUM_ID = 'B04';

SELECT	*	FROM	STADIUM;		/* 19개 (1개 삭재) */
SELECT	*	FROM	TEAM;			/* 14개 (1개 삭재) */
SELECT	*	FROM	SCHEDULE;		/* 143개 (36개 삭재) */
SELECT	*	FROM	PLAYER;			/* 480개 */

-------------------------------------------
-- CASE STUDY 2 : Company DB
-------------------------------------------

USE company;

SELECT	COUNT(*)	FROM	DEPARTMENT;			/* 3개 */
SELECT	COUNT(*)	FROM	EMPLOYEE;			/* 8개 */
SELECT	COUNT(*)	FROM	PROJECT;			/* 6개 */
SELECT	COUNT(*)	FROM	WORKS_ON;			/* 16개 */

DELETE
FROM	EMPLOYEE
WHERE	SSN = '123456789';

SELECT	COUNT(*)	FROM	DEPARTMENT;			/* 3개 */
SELECT	COUNT(*)	FROM	EMPLOYEE;			/* 7개 (1개 삭재) */
SELECT	COUNT(*)	FROM	PROJECT;			/* 6개 */
SELECT	COUNT(*)	FROM	WORKS_ON;			/* 16개 */

-- company DB 초기화한 후, 아래 질의를 실행

SELECT	COUNT(*)	FROM	DEPARTMENT;			/* 3개 */
SELECT	COUNT(*)	FROM	EMPLOYEE;			/* 8개 */
SELECT	COUNT(*)	FROM	PROJECT;			/* 6개 */
SELECT	COUNT(*)	FROM	WORKS_ON;			/* 16개 */

DELETE
FROM	DEPARTMENT
WHERE	DNUMBER = 1;

SELECT	COUNT(*)	FROM	DEPARTMENT;			/* 2개 (1개 삭재) */
SELECT	COUNT(*)	FROM	EMPLOYEE;			/* 7개 (1개 삭재) */
SELECT	COUNT(*)	FROM	PROJECT;			/* 5개 (1개 삭재) */
SELECT	COUNT(*)	FROM	WORKS_ON;			/* 13개 (3개 삭재) */

-- company DB 초기화한 후, 아래 질의를 실행

SELECT	COUNT(*)	FROM	DEPARTMENT;			/* 3개 */
SELECT	COUNT(*)	FROM	EMPLOYEE;			/* 8개 */
SELECT	COUNT(*)	FROM	PROJECT;			/* 6개 */
SELECT	COUNT(*)	FROM	WORKS_ON;			/* 16개 */

DELETE
FROM	DEPARTMENT
WHERE	DNUMBER = 5;

SELECT	COUNT(*)	FROM	DEPARTMENT;			/* 2개 (1개 삭재) */
SELECT	COUNT(*)	FROM	EMPLOYEE;			/* 4개 (3개 삭재) */
SELECT	COUNT(*)	FROM	PROJECT;			/* 3개 (3개 삭재) */
SELECT	COUNT(*)	FROM	WORKS_ON;			/* 7개 (9개 삭재) */
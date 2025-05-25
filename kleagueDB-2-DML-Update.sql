-- Queries for kleague Sample Database
-- Version 1.0

USE kleague;

DESCRIBE PLAYER;
DESCRIBE TEAM;
DESCRIBE STADIUM;
DESCRIBE SCHEDULE;


-------------------------------------------
-- 1. INSERT 문
-------------------------------------------

-- 일반 형식 1

SELECT	*
FROM 	PLAYER
WHERE 	PLAYER_NAME LIKE '박%'
ORDER 	BY PLAYER_NAME;

INSERT INTO 	PLAYER (PLAYER_ID, PLAYER_NAME, TEAM_ID, POSITION, HEIGHT, WEIGHT, BACK_NO) 
VALUES 			('2002007', '박지성', 'K07', 'MF', 178, 73, 7);

SELECT 	*
FROM 	PLAYER
WHERE 	PLAYER_NAME LIKE '박%'
ORDER 	BY PLAYER_NAME;

------------------------------

SELECT 	*
FROM 	PLAYER
WHERE 	PLAYER_NAME LIKE '이%'
ORDER 	BY PLAYER_NAME;

INSERT INTO 	PLAYER 
VALUES 			('2002010','이청용','K07','','BlueDragon','2002','MF','17',NULL,NULL,'1',180,69);

SELECT 	*
FROM 	PLAYER
WHERE 	PLAYER_NAME LIKE '이%'
ORDER 	BY PLAYER_NAME;


-- 일반 형식 2

CREATE TABLE	BLUE_DRAGON_TEAM1 (
	PLAYER_ID   CHAR(7) 		NOT NULL,       
	PLAYER_NAME VARCHAR(20) 	NOT NULL,       
	BACK_NO		TINYINT
);

SELECT 	* 
FROM	BLUE_DRAGON_TEAM1;

INSERT INTO 	BLUE_DRAGON_TEAM1
SELECT	PLAYER_ID, PLAYER_NAME, BACK_NO
FROM	PLAYER
WHERE	TEAM_ID = 'K07';

SELECT	*
FROM	BLUE_DRAGON_TEAM1;

DROP TABLE	BLUE_DRAGON_TEAM1;


-- CTAS와 비교

CREATE TABLE 	BLUE_DRAGON_TEAM2 AS
SELECT	PLAYER_ID, PLAYER_NAME, BACK_NO
FROM	PLAYER
WHERE	TEAM_ID = 'K07';

SELECT	*
FROM	BLUE_DRAGON_TEAM2;

DROP TABLE	BLUE_DRAGON_TEAM2;


-------------------------------------------
-- 2. DELETE 문
-------------------------------------------

SELECT	*
FROM	PLAYER
WHERE	PLAYER_ID = '2002007';			/* 단 하나의 투플만 검색 */

DELETE FROM 	PLAYER
WHERE 			PLAYER_ID = '2002007';

SELECT	*
FROM	PLAYER
WHERE	PLAYER_ID = '2002007';	

-----------------------------

SELECT	*
FROM	PLAYER
WHERE	POSITION = 'GK';				/* 여러개 투플을 검색 */

DELETE FROM 	PLAYER
WHERE			POSITION = 'GK';		/* 에러 */


-- safe_update mode

DELETE FROM 	PLAYER;		/* 에러: safe_update mode로 동작하면, WHERE 절이 없는 DELETE 문은 실행되지 않음. */
							/* 메뉴의 Edit - Preferences - SQL Editor - Other 수정 */
                            
SET sql_safe_updates = 0;		/* Turn off 'Safe Update Mode' */

DELETE FROM 	PLAYER
WHERE			POSITION = 'GK';

SELECT	*
FROM	PLAYER
WHERE	POSITION = 'GK';

DELETE FROM 	PLAYER;

SELECT	*
FROM	PLAYER;

SET sql_safe_updates = 1;	


-------------------------------------------
-- 3. UPDATE 문
-------------------------------------------

-- kleague DB를 초기화한 후, 아래 질의를 실행

SELECT	*
FROM	PLAYER
WHERE	PLAYER_ID = '2000001';

UPDATE	PLAYER
SET		BACK_NO = 99
WHERE	PLAYER_ID = '2000001';

SELECT	*
FROM	PLAYER
WHERE	PLAYER_ID = '2000001';


-- safe_update mode

SELECT	*
FROM	PLAYER;

UPDATE	PLAYER
SET		BACK_NO = 99;		/* 에러 */

SET sql_safe_updates=0;		/* Turn off 'Safe Update Mode' */

UPDATE	PLAYER
SET		BACK_NO = 99;

SELECT	*
FROM	PLAYER;

SET sql_safe_updates=1;
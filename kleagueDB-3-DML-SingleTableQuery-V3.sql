-- Queries for kleague Sample Database
-- Version 1.0

USE kleague;

DESCRIBE PLAYER;
DESCRIBE TEAM;
DESCRIBE STADIUM;
DESCRIBE SCHEDULE;


-------------------------------------------
-- DML : SELECT 문
-------------------------------------------

-- kleague DB를 초기화한 후, 아래 질의를 실행

-- Q: 선수의 모든 정보를 검색

SELECT	*
FROM 	PLAYER;

-- Q: ‘K06’ 팀 선수의 이름, 팀 아이디, 백넘버, 포지션, 키, 몸무게를 검색

SELECT	PLAYER_NAME, TEAM_ID, BACK_NO, POSITION, HEIGHT, WEIGHT
FROM 	PLAYER
WHERE	TEAM_ID = 'K06';

-- Q: ‘K06’ 팀 선수의 이름, 팀 아이디, 백넘버, 포지션, 키, 몸무게, 그리고 비만도를 검색

SELECT	PLAYER_NAME, TEAM_ID, BACK_NO, POSITION, HEIGHT, WEIGHT,
		ROUND(WEIGHT / ((HEIGHT/100)*(HEIGHT/100)), 2) AS 비만도
FROM 	PLAYER
WHERE	TEAM_ID = 'K06';

-------------------------------------------
-- 1. SELECT 절
-------------------------------------------

-- 중복 투플의 제거

SELECT	PLAYER_ID, PLAYER_NAME, TEAM_ID, POSITION, BACK_NO, HEIGHT,	WEIGHT 
FROM 	PLAYER;

 -----------------------------

SELECT DISTINCT	POSITION 
FROM			PLAYER; 

SELECT ALL 		POSITION 
FROM			PLAYER; 

SELECT	POSITION 						/* ALL이 디폴트 값임 */
FROM	PLAYER; 


-- 컬럼 별칭 (column alias)

SELECT	PLAYER_NAME AS 선수명, POSITION AS 위치, HEIGHT AS 키, WEIGHT AS 몸무게 
FROM 	PLAYER;  

SELECT	PLAYER_NAME 선수명, POSITION 위치, HEIGHT 키, WEIGHT 몸무게 
FROM 	PLAYER;							/* AS 생략 가능 */

-----------------------------
 
SELECT	PLAYER_NAME '선수 이름', POSITION '그라운드 포지션', HEIGHT 키, WEIGHT 몸무게 
FROM 	PLAYER;							/* column alias에 공백이 들어갈 때 */

-----------------------------

SELECT	PLAYER_NAME AS 선수명, POSITION AS 위치, HEIGHT AS 키, WEIGHT AS 몸무게 
FROM 	PLAYER
WHERE	선수명 = '김태호';					/* 에러: column alias는 WHERE 절에서는 사용하지 못 함 */

SELECT	PLAYER_NAME AS 선수명, POSITION AS 위치, HEIGHT AS 키, WEIGHT AS 몸무게 
FROM 	PLAYER
WHERE	PLAYER_NAME = '김태호';		


-- 산술연산자

SELECT 	PLAYER_NAME 이름, ROUND(WEIGHT/((HEIGHT/100)*(HEIGHT/100)),2) 'BMI 비만지수'
FROM 	PLAYER;


-- 스트링 합성연산자

SELECT	'MySQL' 'String' 'Concatenation';	/* 'MySQL String Concat' */

SELECT	'MySQL' PLAYER_NAME 'String' 'Concatenation'
FROM	PLAYER;  							/* 에러: MySQL에서 스트링들은 ' '(space)로 연결할 수 있으나, 컬럼명은 연결할 수 없음. */

-----------------------------

SELECT 	CONCAT('MySQL', PLAYER_NAME, 'String', 'Concatenation')
FROM 	PLAYER;

SELECT 	CONCAT(PLAYER_NAME, '선수, ', HEIGHT, 'cm, ', WEIGHT, 'kg') AS 체격정보 
FROM 	PLAYER;

-------------------------------------------
-- 2. WHERE 절
-------------------------------------------

-- 비교연산자
-- 'K02' AND 'K02' TEAMS' POS, PLAYER_NAME, BACK_NO , HEIGHT, TEAM_ID OF PLAYERS WHO IS NOT 'MF' AND WHOSE HEIGHT IS 170 ~ 180;;
SELECT 	TEAM_ID, PLAYER_NAME 선수이름, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	(TEAM_ID = 'K02' OR TEAM_ID = 'K07') AND 
		POSITION <> 'MF' AND 
		HEIGHT >= 170 AND HEIGHT <= 180;

-- IN 연산자 

SELECT 	TEAM_ID, PLAYER_NAME 선수이름, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	TEAM_ID IN ('K02','K07'); 		/* TEAM_ID = 'K02' OR TEAM_ID = 'K07' */

-- SELECT BRAZILIAN 'MF'S AND RUSSIAN FW.
SELECT 	PLAYER_NAME, TEAM_ID, POSITION, NATION
FROM 	PLAYER 
WHERE 	(POSITION, NATION) IN (('MF','브라질'), ('FW', '러시아')); 
				/* (POSITION, NATION) = ('MF','브라질') OR (POSITION, NATION) = ('FW','러시아') */


SELECT 	PLAYER_NAME, TEAM_ID, POSITION, NATION
FROM 	PLAYER 
WHERE 	POSITION IN ('MF', 'FW') AND NATION IN ('브라질', '러시아');
				/* (POSITION = 'MF' OR POSITION = 'FW') AND (NATION = '브라질' OR NATION = '러시아') */

-- LIKE 연산자


SELECT 	PLAYER_NAME 선수이름, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	POSITION LIKE 'MF';	

-- SELECT ALL PLAYERS WHOSE NAME STARTS WITH '장'

SELECT 	PLAYER_NAME 선수이름, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	PLAYER_NAME LIKE '장%';


-- BETWEEN a AND b 연산자

SELECT 	PLAYER_NAME 선수이름, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	HEIGHT BETWEEN 170 AND 180;			/* HEIGHT >= 170 AND HEIGHT <= 180 */

-- IS NULL 연산자

SELECT 	PLAYER_NAME 선수이름, POSITION 포지션, TEAM_ID 
FROM 	PLAYER 
WHERE 	POSITION = NULL;		/* 'POSITION = NULL'은 항상 FALSE를 리턴함 (NULL과의 비교는 항상 FALSE)*/ 

SELECT 	PLAYER_NAME 선수이름, POSITION 포지션, TEAM_ID 
FROM 	PLAYER 
WHERE 	POSITION IS NULL;


-- 논리연산자

SELECT 	PLAYER_NAME 선수이름, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 , TEAM_ID
FROM 	PLAYER 
WHERE 	(TEAM_ID = 'K02' OR TEAM_ID = 'K07') AND
		POSITION = 'MF' AND 
		HEIGHT >= 170 AND HEIGHT <= 180;  



SELECT 	PLAYER_NAME 선수이름, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 , TEAM_ID
FROM 	PLAYER 
WHERE 	TEAM_ID IN ('K02','K07') AND
		POSITION = 'MF' AND 
		HEIGHT BETWEEN 170 AND 180;


-------------------------------------------
-- 3. GROUP BY / HAVING 절과 집계 함수
-------------------------------------------

-------------------------------------------
-- 3.1 집계 함수
-------------------------------------------

-- COUNT() 함수


SELECT	COUNT(PLAYER_ID), COUNT(*)			/* 널이 아닌 값의 개수를 세는 함수 */
FROM	PLAYER;


SELECT	COUNT(PLAYER_ID), COUNT(TEAM_ID), COUNT(POSITION), 
		COUNT(BACK_NO), COUNT(HEIGHT)
FROM	PLAYER;

SELECT	COUNT(PLAYER_ID), COUNT(DISTINCT TEAM_ID), COUNT(DISTINCT POSITION), 
		COUNT(DISTINCT BACK_NO), COUNT(DISTINCT HEIGHT)
FROM	PLAYER;


-- SUM(), AVG() 함수

SELECT 	ROUND(SUM(HEIGHT)/COUNT(*),1) AS '잘못된 평균키', 
		ROUND(SUM(HEIGHT)/COUNT(HEIGHT),1) AS '올바른 평균키', 
        ROUND(AVG(HEIGHT),1) AS 'AVG 함수'
FROM 	PLAYER;


-------------------------------------------
-- 3.2 GROUP BY 절
-------------------------------------------

SELECT	PLAYER_NAME, POSITION, HEIGHT,TEAM_ID
FROM	PLAYER
WHERE	TEAM_ID = 'K10';

-- Q : Aggregate function
-- find position and average height of team 'k10' and group by position.

SELECT	POSITION, AVG(HEIGHT) AS HEIGHT_AVG
FROM	PLAYER
WHERE	TEAM_ID = 'K10'
GROUP 	BY POSITION;						/* 그룹핑 기준 컬럼 (그룹 명칭 역할) */

SELECT	AVG(HEIGHT) AS HEIGHT_AVG			/* GROUP BY 절 없이 집계 함수를 사용할 때 */
FROM	PLAYER
WHERE	TEAM_ID = 'K10';

-----------------------------
SELECT 	*
FROM 	PLAYER;

-- print position , number of the players, number of non null heights,max height, min height, and average height --> position group
SELECT 	POSITION 포지션, COUNT(*) 인원수, COUNT(HEIGHT) 키대상,		/* COUNT(HEIGHT)는 모두 NULL이면, 0 리턴 */
		MAX(HEIGHT) 최대키, MIN(HEIGHT) 최소키,
		ROUND(AVG(HEIGHT),2) 평균키 
FROM 	PLAYER 
GROUP 	BY POSITION;						/* 그룹핑 기준 컬럼 (그룹 명칭 역할) */

-----------------------------
/* SELECT 절의 타겟 리스트에는 aggregated column만 사용할 수 있음 */

SELECT 	POSITION 포지션, COUNT(*) 인원수, COUNT(HEIGHT) 키대상,
		MAX(HEIGHT) 최대키, MIN(HEIGHT) 최소키,
		ROUND(AVG(HEIGHT),2) 평균키, 
        PLAYER_NAME							/* 에러 : PLAYER_NAME은 aggregated column이 아님 */
FROM 	PLAYER 
GROUP 	BY POSITION;


-------------------------------------------
-- 3.3 HAVING 절
-------------------------------------------

SELECT 	TEAM_ID 팀아이디, COUNT(*) 인원수 
FROM 	PLAYER
GROUP 	BY TEAM_ID;

/* 그룹핑 기준 컬럼으로 그룹_조건식 서술 (아래 두 질의 결과는 같음) */

-- team_id , and player number of team 'k09' and 'k02'
SELECT 	TEAM_ID 팀아이디, COUNT(*) 인원수 
FROM 	PLAYER 
GROUP 	BY TEAM_ID  HAVING TEAM_ID IN ('K09', 'K02');	/* 그룹_조건식 */

SELECT 	TEAM_ID 팀ID, COUNT(*) 인원수 
FROM 	PLAYER 
WHERE 	TEAM_ID IN ('K09', 'K02') 			/* 투플_조건식 */
GROUP 	BY TEAM_ID;							/* 같은 결과이나, 성능이 더 좋음 */

-----------------------------
/* 집계 함수로 그룹_조건식 서술 */
-- find the names which happened to be in the database more than 2 times

SELECT	PLAYER_NAME AS '선수 이름', COUNT(PLAYER_NAME) AS '동명이인의 인원수'
FROM	PLAYER
GROUP 	BY PLAYER_NAME 	HAVING	COUNT(PLAYER_NAME) >= 2;	/* 그룹_조건식 */

/* 집계 함수로 그룹_조건식 서술 */
-- find positions where average height is greater than 180

SELECT	POSITION 포지션, ROUND(AVG(HEIGHT),2) 평균키 
FROM 	PLAYER 
GROUP 	BY POSITION   HAVING AVG(HEIGHT) >= 180;			/* 그룹_조건식 */

SELECT	POSITION 포지션, ROUND(AVG(HEIGHT),2) 평균키 
FROM 	PLAYER
WHERE 	AVG(HEIGHT) >= 180							/* 에러: WHERE 절에서는 집계 함수를 사욜할 수 없음. */
GROUP 	BY POSITION;

-----------------------------
/* Note : 아래 두 명령어의 결과는 동일함. */    
    
SELECT POSITION, AVG(HEIGHT)
FROM   PLAYER
GROUP BY POSITION HAVING AVG(HEIGHT) >= 180;

WITH TEMP AS (
	SELECT POSITION, AVG(HEIGHT) AS AVG_HEIGHT		/* 컬럼 별칭 */
	FROM   PLAYER
	GROUP BY POSITION
)
SELECT	POSITION, AVG_HEIGHT
FROM	TEMP
WHERE	AVG_HEIGHT >= 180;							/* 컬럼 */


-------------------------------------------
-- 4. ORDER BY 절
-------------------------------------------

SELECT 	PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버 
FROM 	PLAYER 
ORDER 	BY 포지션 ASC; 				/** NULL이 처음에 위치함. */

SELECT 	PLAYER_NAME 선수이름, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	HEIGHT IS NOT NULL 			/* '키 IS NOT NULL'은 에러 */
ORDER 	BY 키 DESC, BACK_NO; 

-- find non null back_no fuckers and sort them back_no is descending , position and player name are ascending.

SELECT 	PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버
FROM 	PLAYER 
WHERE 	BACK_NO IS NOT NULL 
ORDER 	BY 3 DESC, 2, 1; 


-----------------------------
/* 아래 세 질의는 모두 동일함 */

SELECT 	POSITION 포지션, BACK_NO, PLAYER_NAME 			
FROM 	PLAYER
ORDER 	BY POSITION, BACK_NO, PLAYER_NAME DESC; 

SELECT 	POSITION 포지션, BACK_NO, PLAYER_NAME 
FROM 	PLAYER
ORDER 	BY 포지션, BACK_NO, PLAYER_NAME DESC; 

SELECT 	POSITION 포지션, BACK_NO, PLAYER_NAME 
FROM 	PLAYER
ORDER 	BY 포지션, 2, 3 DESC; 

-----------------------------
/* ORDER BY 절에는 SELECT 목록에 나타나지 않은 컬럼이 포함될 수 있음. */

SELECT	PLAYER_ID, POSITION
FROM	PLAYER
ORDER	BY PLAYER_NAME;			/* SELECT 절에 없는 컬럼으로 정렬 가능함 */

/* GROUP BY 절을 같이 사용하면, SELECT 목록에 없는 컬럼을 ORDER BY에 사용할 수 없음 */
SELECT	POSITION, COALESCE(AVG(HEIGHT),0), COALESCE(AVG(WEIGHT),0)
FROM	PLAYER
GROUP 	BY POSITION	
ORDER	BY PLAYER_NAME;			/* 에러: PLAYER_NAME는 SELECT 목록에 없는 컬럼 */


-------------------------------------------
-- 5. LIMIT 절
-------------------------------------------

SELECT	STADIUM_ID, STADIUM_NAME, SEAT_COUNT
FROM	STADIUM
ORDER	BY SEAT_COUNT DESC, STADIUM_NAME;


SELECT	STADIUM_ID, STADIUM_NAME, SEAT_COUNT
FROM	STADIUM
ORDER	BY SEAT_COUNT DESC, STADIUM_NAME
LIMIT	3;								/* "LIMIT 0, 3;" 과 같은 결과, 0번째 부터 최대 3개*/

-- FIND TOP 11-16 BIGGEST SEAT_COUNT STADIUM'S STADIUM_ID , STADIUM_NAME, SEAT_COUNT. IF SEAT_COUNT IS THE SAME, SORT BY STADIUM NAME

SELECT	STADIUM_ID, STADIUM_NAME, SEAT_COUNT
FROM	STADIUM
ORDER	BY SEAT_COUNT DESC, STADIUM_NAME
LIMIT	10, 5;							/* 11번째 부터 최대 5개 */


-------------------------------------------
-- Note : Top-n query
-------------------------------------------

SELECT 	ROW_NUMBER() OVER (ORDER BY SEAT_COUNT DESC) AS ROW_NUM, 	/* 컬럼 별칭으로 ROW_NUMBER 사용 못 함 */
		STADIUM_ID, STADIUM_NAME, SEAT_COUNT, 
		RANK() OVER (ORDER BY SEAT_COUNT DESC) AS SEAT_RANK			/* 컬럼 별칭으로 RANK 사용 못 함 */ 
FROM 	STADIUM;

-- Q : 좌석수 많은 10개 경기장 (아래 두 질의 결과는 동일함)

WITH TEMP AS
(
		SELECT 	STADIUM_ID, STADIUM_NAME, SEAT_COUNT, 
				ROW_NUMBER() OVER (ORDER BY SEAT_COUNT DESC) AS ROW_NUM		/* ROW_NUM은 컬럼 별칭 */
		FROM 	STADIUM
)
SELECT	STADIUM_ID, STADIUM_NAME, SEAT_COUNT, ROW_NUM
FROM	TEMP
WHERE	ROW_NUM <= 10;					/* ROW_NUM은 컬럼 */


SELECT	STADIUM_ID, STADIUM_NAME, SEAT_COUNT
FROM	STADIUM
ORDER 	BY SEAT_COUNT DESC
LIMIT 	10;


-- Q : 좌석수 많은 순위로 10위까지의 경기장

WITH TEMP AS
(
		SELECT 	STADIUM_ID, STADIUM_NAME, SEAT_COUNT, 
				RANK() OVER (ORDER BY SEAT_COUNT DESC) AS SEAT_RANK			/* SEAT_RANK은 컬럼 별칭 */
		FROM 	STADIUM
)
SELECT	STADIUM_ID, STADIUM_NAME, SEAT_COUNT, SEAT_RANK
FROM	TEMP
WHERE	SEAT_RANK <= 10;				/* SEAT_RANK은 컬럼 */


-- Note : 아래 두 질의는 에러임 (컬럼 별칭은 WHERE 절에서 사용할 수 없음)
SELECT 	STADIUM_ID, STADIUM_NAME, SEAT_COUNT,
		ROW_NUMBER() OVER (ORDER BY SEAT_COUNT DESC) AS ROW_NUM
FROM 	STADIUM
WHERE	ROW_NUM <= 10;					/* ROW_NUM은 컬럼 별칭 */

SELECT 	STADIUM_ID, STADIUM_NAME, SEAT_COUNT,
		RANK() OVER (ORDER BY SEAT_COUNT DESC) AS SEAT_RANK
FROM 	STADIUM
WHERE	SEAT_RANK <= 10;				/* SEAT_RANK은 컬럼 별칭 */


-------------------------------------------
-- Note :  윈도우 함수의 ORDER BY 절과 SELECT 문의 ORDER BY 절
-------------------------------------------

SELECT 	STADIUM_ID, STADIUM_NAME, SEAT_COUNT, 
		RANK() OVER (ORDER BY SEAT_COUNT DESC, STADIUM_NAME) AS SEAT_RANK	/* STADIUM_NAME 추가 */
FROM 	STADIUM;

SELECT 	STADIUM_ID, STADIUM_NAME, SEAT_COUNT, 
		RANK() OVER (ORDER BY SEAT_COUNT DESC) AS SEAT_RANK		/* 결과를 생성하기 위한 정렬 방법 */
FROM 	STADIUM
ORDER 	BY SEAT_COUNT DESC, STADIUM_NAME;						/* 생성된 결과의 출력을 위한 정렬 방법 */


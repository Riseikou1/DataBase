-- Queries for kleague Sample Database
-- Version 1.0

USE kleague;

DESCRIBE PLAYER;
DESCRIBE TEAM;
DESCRIBE STADIUM;
DESCRIBE SCHEDULE;


-------------------------------------------
-- 1. DML Algebra : 집합 연산자
-------------------------------------------

-------------------------------------------
-- 1.1 UNION 연산
-------------------------------------------

/* UNION 연산은 WHERE 절의 OR 혹은 IN 연산으로 표현 가능 */
/* 아래 세 질의의 결과는 모두 동일함 */

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키  
FROM 	PLAYER
WHERE 	TEAM_ID = 'K02' 
UNION 
SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER
WHERE 	TEAM_ID = 'K07'
ORDER	BY 선수명;


SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	TEAM_ID = 'K02' OR TEAM_ID = 'K07'
ORDER	BY 선수명;

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	TEAM_ID IN ('K02','K07')
ORDER	BY 선수명;

------------------------------

/* UNION ALL과 UNION DISTINCT */

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	TEAM_ID = 'K01' 
UNION 	ALL
SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	POSITION = 'GK'
ORDER	BY 팀코드, 선수명;

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	TEAM_ID = 'K01' 
UNION 	DISTINCT
SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	POSITION = 'GK'
ORDER	BY 팀코드, 선수명;				/* 디폴트임 */

------------------------------

/* union compatible 개념 */

SELECT 	'P' 구분코드, POSITION 포지션, AVG(HEIGHT) 평균키 
FROM 	PLAYER 
GROUP 	BY POSITION 
UNION 
SELECT 	'T' 구분코드, TEAM_ID 팀아이디, AVG(HEIGHT) 평균키 
FROM 	PLAYER 
GROUP 	BY TEAM_ID 
ORDER 	BY 1;


-------------------------------------------
-- 1.2 INTERSECT 연산
-------------------------------------------

-- Q: 소속이 K02 팀이면서 포지션이 GK인 선수들을 검색. (INTERSECT 연산)


SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 	
FROM 	PLAYER
WHERE 	TEAM_ID = 'K02' 
INTERSECT 
SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	POSITION = 'GK' 
ORDER 	BY 1, 2, 3, 4, 5;

/* INTERSECT 연산은 WHERE 절의 AND 혹은 subquery로 표현 가능 (아래 세 질의의 결과는 모두 동일함) */

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	TEAM_ID = 'K02' AND POSITION = 'GK' 
ORDER 	BY 1, 2, 3, 4, 5;

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER
WHERE 	TEAM_ID = 'K02' AND 
		PLAYER_ID IN (	SELECT 	PLAYER_ID 
						FROM 	PLAYER 
						WHERE 	POSITION = 'GK') 
ORDER 	BY 1, 2, 3, 4, 5;


SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER X
WHERE 	X.TEAM_ID = 'K02' AND 
		EXISTS (	SELECT 	1 
					FROM 	PLAYER Y 
					WHERE 	Y.PLAYER_ID = X.PLAYER_ID AND Y.POSITION = 'GK') 
ORDER 	BY 1, 2, 3, 4, 5;



-------------------------------------------
-- 1.3 EXCEPT 연산
-------------------------------------------

-- Q: 소속이 K02 팀이면서 포지션이 MF가 아닌 선수들을 검색


SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 		
FROM 	PLAYER
WHERE 	TEAM_ID = 'K02'
EXCEPT
SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	POSITION = 'MF' 
ORDER 	BY 1, 2, 3, 4, 5; 

/* EXCEPT 연산은 WHERE 절의 AND 혹은 subquery로 표현 가능 (아래 세 질의의 결과는 모두 동일함) */

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키
FROM 	PLAYER 
WHERE 	TEAM_ID = 'K02' AND POSITION <> 'MF' 
ORDER 	BY 1, 2, 3, 4, 5;


SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	TEAM_ID = 'K02' AND 
		PLAYER_ID NOT IN (	SELECT  PLAYER_ID
							FROM 	PLAYER 
							WHERE	POSITION = 'MF') 
ORDER 	BY 1, 2, 3, 4, 5; 


SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER X
WHERE 	X.TEAM_ID = 'K02' AND 
		NOT EXISTS (	SELECT 	1 
						FROM 	PLAYER Y 
						WHERE 	Y.PLAYER_ID = X.PLAYER_ID AND POSITION = 'MF') 
ORDER 	BY 1, 2, 3, 4, 5;

-------------------------------------------
-- 2. DML Algebra : WHERE 절 JOIN (inner join 기능만 지원함)
-------------------------------------------

-- Q: 선수들의 이름, 백넘버, 소속 팀명 및 팀 연고지를 검색하라. (아래 두 질의의 결과는 동일함)

SELECT 	PLAYER.PLAYER_NAME, PLAYER.BACK_NO, PLAYER.TEAM_ID, 
		TEAM.TEAM_NAME, TEAM.REGION_NAME 
FROM 	PLAYER, TEAM 
WHERE 	PLAYER.TEAM_ID = TEAM.TEAM_ID;							/* WHERE 절 조인 */

SELECT 	PLAYER.PLAYER_NAME, PLAYER.BACK_NO, PLAYER.TEAM_ID, 
		TEAM.TEAM_NAME, TEAM.REGION_NAME 
FROM 	PLAYER JOIN TEAM ON PLAYER.TEAM_ID = TEAM.TEAM_ID; 		/* FROM 절 조인 */

-- Q: 포지션이 ‘GK’인 선수들의 이름, 백넘버, 소속 팀명 및 팀 연고지를 검색하라. 
--    단, 백넘버의 오름차순으로 출력하라. (아래 두 질의의 결과는 동일함)


SELECT 	PLAYER.PLAYER_NAME, PLAYER.BACK_NO, PLAYER.TEAM_ID,
		TEAM.TEAM_NAME, TEAM.REGION_NAME
FROM 	PLAYER, TEAM
WHERE 	PLAYER.POSITION = 'GK' AND
		PLAYER.TEAM_ID = TEAM.TEAM_ID 	/* 조인 조건과 검색 조건이 WHERE 절에서 같이 서술됨 */
ORDER 	BY PLAYER.BACK_NO;

SELECT 	PLAYER.PLAYER_NAME, PLAYER.BACK_NO, PLAYER.TEAM_ID,
		TEAM.TEAM_NAME, TEAM.REGION_NAME 
FROM 	PLAYER JOIN TEAM ON PLAYER.TEAM_ID = TEAM.TEAM_ID	/* 조인 조건은 FROM 절 */
WHERE 	PLAYER.POSITION = 'GK'								/* 검색 조건은 WHERE 절 */
ORDER 	BY PLAYER.BACK_NO;


-- Q: 선수들의 이름, 백넘버, 소속 팀명 및 팀 연고지를 검색하라. (아래 두 질의의 결과는 동일함)


/* Table alias의 사용 */

SELECT 	P.PLAYER_NAME 선수명, P.BACK_NO 백넘버, P.TEAM_ID 팀코드, 
		T.TEAM_NAME 소속팀, T.REGION_NAME 연고지 
FROM 	PLAYER P, TEAM T 
WHERE 	P.TEAM_ID = T.TEAM_ID;									/* WHERE 절 조인 */

SELECT 	P.PLAYER_NAME 선수명, P.BACK_NO 백넘버, P.TEAM_ID 팀코드, 
		T.TEAM_NAME 소속팀, T.REGION_NAME 연고지 
FROM 	PLAYER P JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID; 			/* FROM 절 조인 */

------------------------------

/* 컬럼명의 경우, 속한 테이블이 명백하면 테이블 별칭(table alias)를 생략할 수 있음 */

SELECT 	PLAYER_NAME 선수명, BACK_NO 백넘버, P.TEAM_ID 팀코드, 		/* TEAM_ID는 두 테이블에 모두 있음 */
		TEAM_NAME 소속팀, REGION_NAME 연고지 
FROM 	PLAYER P, TEAM T 
WHERE 	P.TEAM_ID = T.TEAM_ID;


-- Q: 다중 테이블 조인 - 선수, 팀, 경기장의 관계 (아래 두 질의의 결과는 동일함)


SELECT 	P.PLAYER_NAME 선수명, P.POSITION 포지션, 
		T.TEAM_NAME 소속팀, T.REGION_NAME 연고지, 
		ST.STADIUM_NAME 전용구장, ST.SEAT_COUNT 좌석수
FROM 	PLAYER P, TEAM T, STADIUM ST 
WHERE 	P.TEAM_ID = T.TEAM_ID AND 
		T.STADIUM_ID = ST.STADIUM_ID 
ORDER 	BY 선수명;

SELECT 	P.PLAYER_NAME 선수명, P.POSITION 포지션, 
		T.TEAM_NAME 소속팀, T.REGION_NAME 연고지, 
		ST.STADIUM_NAME 전용구장, ST.SEAT_COUNT 좌석수
FROM 	PLAYER P 
		JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID
		JOIN STADIUM ST ON T.STADIUM_ID = ST.STADIUM_ID 
ORDER 	BY 선수명;

------------------------------
/* 조인의 순서를 바꾸어도 결과는 동일함 (아래 두 질의의 결과는 동일함) */

SELECT 	P.PLAYER_NAME 선수명, P.POSITION 포지션, 
		T.TEAM_NAME 소속팀, T.REGION_NAME 연고지, 
		ST.STADIUM_NAME 전용구장, ST.SEAT_COUNT 좌석수
FROM 	PLAYER P, TEAM T, STADIUM ST
WHERE 	P.TEAM_ID = T.TEAM_ID AND T.STADIUM_ID = ST.STADIUM_ID 
ORDER 	BY 선수명;

SELECT 	P.PLAYER_NAME 선수명, P.POSITION 포지션, 
		T.TEAM_NAME 소속팀, T.REGION_NAME 연고지, 
		ST.STADIUM_NAME 전용구장, ST.SEAT_COUNT 좌석수
FROM 	PLAYER P, TEAM T, STADIUM ST 
WHERE 	T.STADIUM_ID = ST.STADIUM_ID AND P.TEAM_ID = T.TEAM_ID
ORDER 	BY 선수명;


-- Q: 팀과 전용 경기장의 전화번호가 같은 팀을 검색 (PK-FK 관계가 아닌 속성을 조인 속성으로 사용)

SELECT TEAM_NAME, STADIUM_NAME, TEAM.TEL
FROM TEAM JOIN STADIUM ON TEAM.TEL = STADIUM.TEL;

SELECT 	TEAM_NAME, STADIUM_NAME, TEAM.TEL
FROM 	TEAM, STADIUM 
WHERE 	TEAM.TEL = STADIUM.TEL;      /* TEL은 PK, FK가 아닌 일반 속성 */


-- Q: 선수의 키 등급 (비둥가 조인)

CREATE TABLE HEIGHT_GRADE (
	GRADE	TINYINT		NOT NULL,
    LOW		MEDIUMINT	NOT NULL,
    HIGH	MEDIUMINT	NOT NULL,
	CONSTRAINT 	PK_HEIGHT_GRADE 	PRIMARY KEY (GRADE)
);

INSERT INTO HEIGHT_GRADE VALUES
(1, 190, 250),
(2, 185, 189),
(3, 180, 184),
(4, 175, 179),
(5, 170, 174),
(6, 0, 169);

SELECT * FROM HEIGHT_GRADE;
-- DISPLAY , PLAYER_NAME , HEIGHT AND HEIGHT LEVEL OF TEAM 'K04'S DF. HEIGHT -> TALLEST TO SHORTEST .

SELECT 	PLAYER_NAME, HEIGHT 
FROM 	PLAYER
WHERE	TEAM_ID = 'K04' AND POSITION = 'DF';


SELECT 	PLAYER_NAME, HEIGHT, GRADE
FROM 	PLAYER P, HEIGHT_GRADE G 
WHERE 	TEAM_ID = 'K04' AND POSITION = 'DF' AND		/* 검색 조건 */
		P.HEIGHT BETWEEN G.LOW AND G.HIGH			/* 조인 조건 */
ORDER 	BY HEIGHT DESC;

SELECT 	PLAYER_NAME, HEIGHT, GRADE
FROM 	PLAYER P JOIN HEIGHT_GRADE G ON P.HEIGHT BETWEEN G.LOW AND G.HIGH	/* 조인 조건 */
WHERE 	TEAM_ID = 'K04' AND POSITION = 'DF'			/* 검색 조건 */
ORDER 	BY HEIGHT DESC;

DROP TABLE HEIGHT_GRADE;

-------------------------------------------
-- 3. DML Algebra : FROM 절 JOIN
-------------------------------------------

USE kleague;

-------------------------------------------
-- 3.1 INNER JOIN
-------------------------------------------

-- Q: ON 절과 USING 절의 사용 조건

/* 조인 속성의 명칭이 같을 때, ON 절 및 USING 절 모두 사용 가능함. (아래 두 질의의 결과는 동일함) */

-- RETURN TEAM_NAME, WITH ITS STADIUM'S ID AND NAME.
SELECT 	TEAM_NAME, TEAM.STADIUM_ID, STADIUM_NAME 				 
FROM 	TEAM JOIN STADIUM ON TEAM.STADIUM_ID = STADIUM.STADIUM_ID 
ORDER 	BY STADIUM_ID;

SELECT 	TEAM_NAME, TEAM.STADIUM_ID, STADIUM_NAME
FROM 	TEAM JOIN STADIUM USING (STADIUM_ID)
ORDER 	BY STADIUM_ID;

/* 조인 속성의 명칭이 다를 때, ON절을 사용해야 함. (USING 절은 사용할 수 없음.) */

SELECT	S.STADIUM_ID, SCHE_DATE, 
		TEAM_NAME AS HOME_TEAM_NAME, AWAYTEAM_ID, 
		HOME_SCORE, AWAY_SCORE
FROM	SCHEDULE S JOIN TEAM T ON S.HOMETEAM_ID = T.TEAM_ID;


-- Q: ON 절과 USING 절의 출력 차이 (테이블 전체를 출력할 때)

WITH TEAM_TEMP AS
(
	SELECT	TEAM_ID, TEAM_NAME, STADIUM_ID
    FROM	TEAM
),
STADIUM_TEMP AS
(
	SELECT 	STADIUM_ID, STADIUM_NAME, SEAT_COUNT
    FROM	STADIUM
)
SELECT	*
FROM	TEAM_TEMP T JOIN STADIUM_TEMP S ON T.STADIUM_ID = S.STADIUM_ID;		/* 속성의 순서에 주의, equi-join과 동일 */

WITH TEAM_TEMP AS
(
	SELECT	TEAM_ID, TEAM_NAME, STADIUM_ID
    FROM	TEAM
),
STADIUM_TEMP AS
(
	SELECT 	STADIUM_ID, STADIUM_NAME, SEAT_COUNT
    FROM	STADIUM
)
SELECT	*
FROM	TEAM_TEMP JOIN STADIUM_TEMP USING (STADIUM_ID);				/* 속성의 순서에 주의, natural join과 동일 */


-- Q: ON 절과 USING 절의 출력 차이에서 기인한 재미있는 문제

SELECT	*
FROM	PLAYER JOIN TEAM ON PLAYER.TEAM_ID = TEAM.TEAM_ID;

CREATE TABLE TEMP AS					/* 에러: TEAM_ID가 두 개임. */
SELECT	*
FROM	PLAYER JOIN TEAM ON PLAYER.TEAM_ID = TEAM.TEAM_ID;

SELECT	*
FROM	PLAYER JOIN TEAM USING (TEAM_ID);

CREATE TABLE TEMP AS					/* 에러없이 저장됨 */
SELECT	*
FROM	PLAYER JOIN TEAM USING (TEAM_ID);

DROP TABLE TEMP;	


-- Q: 다중 테이블 조인 1
-- GK 포지션의 선수 마다 연고지명, 팀명, 구장명을 출력함. 

SELECT 	PLAYER_NAME 선수명, POSITION 포지션, 
		REGION_NAME 연고지, TEAM_NAME 팀명, STADIUM_NAME 구장명 
FROM 	PLAYER 
		JOIN TEAM ON PLAYER.TEAM_ID = TEAM.TEAM_ID
		JOIN STADIUM ON TEAM.STADIUM_ID = STADIUM.STADIUM_ID
WHERE	POSITION ='GK'
ORDER 	BY 선수명;

SELECT 	PLAYER_NAME 선수명, POSITION 포지션, 
		REGION_NAME 연고지, TEAM_NAME 팀명, STADIUM_NAME 구장명 
FROM 	PLAYER 
		JOIN TEAM USING (TEAM_ID) 
		JOIN STADIUM USING (STADIUM_ID) 
WHERE 	POSITION = 'GK' 
ORDER 	BY 선수명;

SELECT 	PLAYER_NAME 선수명, POSITION 포지션, 
		REGION_NAME 연고지, TEAM_NAME 팀명, STADIUM_NAME 구장명 
FROM 	PLAYER 
		JOIN TEAM ON PLAYER.TEAM_ID = TEAM.TEAM_ID
		JOIN STADIUM USING (STADIUM_ID) 
WHERE	POSITION ='GK'
ORDER 	BY 선수명;

------------------------------
/* 조인의 순서를 바꾸어도 결과는 동일함 (아래 두 질의의 결과는 동일함) */

SELECT 	P.PLAYER_NAME 선수명, P.POSITION 포지션, 
		T.TEAM_NAME 소속팀, T.REGION_NAME 연고지, 
		S.STADIUM_NAME 전용구장, S.SEAT_COUNT 좌석수
FROM 	PLAYER P 
		JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID
		JOIN STADIUM S ON T.STADIUM_ID = S.STADIUM_ID 
ORDER 	BY 선수명;

SELECT 	P.PLAYER_NAME 선수명, P.POSITION 포지션, 
		T.TEAM_NAME 소속팀, T.REGION_NAME 연고지, 
		S.STADIUM_NAME 전용구장, S.SEAT_COUNT 좌석수
FROM 	TEAM T 
		JOIN STADIUM S ON T.STADIUM_ID = S.STADIUM_ID 
		JOIN PLAYER P ON P.TEAM_ID = T.TEAM_ID
ORDER 	BY 선수명;


-- Q: 다중 테이블 조인 2
-- 홈팀이 3점 이상 차이로 승리한 경기의 경기장명, 경기 일정, 홈팀명과 원정팀명을 출력함.

/* step 1 */

SELECT 	*
FROM 	SCHEDULE
WHERE 	GUBUN = 'Y' AND HOME_SCORE >= AWAY_SCORE + 3;

/* step 2 */

SELECT 	STADIUM_NAME AS 경기장명, SCHE_DATE AS 경기일정, 
		HT.TEAM_NAME AS 홈팀명, AT.TEAM_NAME AS 원정팀명, 
		HOME_SCORE AS '홈팀 점수', AWAY_SCORE AS '원정팀 점수' 
FROM 	SCHEDULE SC JOIN STADIUM ST ON SC.STADIUM_ID = ST.STADIUM_ID 
		JOIN TEAM HT ON SC.HOMETEAM_ID = HT.TEAM_ID 
		JOIN TEAM AT ON SC.AWAYTEAM_ID = AT.TEAM_ID 
WHERE 	GUBUN = 'Y' AND HOME_SCORE >= AWAY_SCORE + 3;


-------------------------------------------
-- 3.2 NATURAL JOIN
-------------------------------------------

-- Q: NATURAL JOIN과 INNER JOIN의 출력 차이

SELECT 	* 	
FROM 	PLAYER NATURAL JOIN TEAM; 					/* TEAM_ID가 맨 앞에 한 번만 나옴 */			

SELECT 	* 
FROM 	PLAYER INNER JOIN TEAM ON PLAYER.TEAM_ID = TEAM.TEAM_ID; 		/* 결과에 TEAM_ID가 두 번 나옴 */		

SELECT 	* 
FROM 	PLAYER INNER JOIN TEAM USING (TEAM_ID); 	/* NATURAL JOIN과 결과가 동이함. */


-- Q: NATURAL JOIN은 두 테이블 간의 동일한 이름(같은 데이터 유형이어야 함)을 갖는 
-- “모든” 컬럼 (조인 속성)들에 대해 equi-join을 수행함. 

SELECT 	TEAM_NAME, STADIUM_ID, STADIUM_NAME 	/* 공톻되는 애츠리뷰트가 STADIUM_ID, ADDRESS, DDD, TEL 네 개가 있음. */ 
FROM 	TEAM NATURAL JOIN STADIUM 				/* 이 네 개 값이 모두 일치하는 경우는 없으므로, 결과가 공집합 */
ORDER 	BY STADIUM_ID;

SELECT 	TEAM_NAME, STADIUM_ID, STADIUM_NAME 
FROM 	TEAM JOIN STADIUM USING (STADIUM_ID); 	/* STADIUM_ID만으로 조인하므로 실행됨 */

ALTER TABLE STADIUM
DROP COLUMN ADDRESS,
DROP COLUMN DDD,
DROP COLUMN TEL;								/* DROP COLUMN ADDRESS, DDD, TEL; 는 허용되지 않음 */

SELECT 	TEAM_NAME, STADIUM_ID, STADIUM_NAME 	/* 공톻되는 애츠리뷰트는 STADIUM_ID만 존재 */ 
FROM 	TEAM NATURAL JOIN STADIUM 
ORDER 	BY STADIUM_ID;


-- kleague DB를 초기화한 후, 아래 질의를 실행

-- Q: 선수, 팀, 경기장 테이블을 모두 조인하는 가장 간단한 형태 

SELECT 	PLAYER_ID, PLAYER_NAME, POSITION, BACK_NO, TEAM_NAME, STADIUM_NAME 	
FROM 	PLAYER 
		NATURAL JOIN TEAM
		INNER JOIN STADIUM USING (STADIUM_ID);


-------------------------------------------
-- 3.3 LEFT/RIGHT OUTER JOIN
-------------------------------------------

-- Q: TEAM 테이블과 STADIUM 테이블 간의 OUTER JOIN
-- TEAM에는 2개 투플, STADIUM에는 2개 투플이 INNER JOIN이 불가능한 투플임.

SELECT	TEAM_ID, TEAM_NAME, REGION_NAME, STADIUM_ID
FROM	TEAM;

ALTER TABLE 	TEAM
MODIFY COLUMN 	STADIUM_ID	CHAR(3);					/* NOT NULL 제약조건을 제거 */

INSERT INTO TEAM (TEAM_ID, REGION_NAME, TEAM_NAME, STADIUM_ID) VALUES 
('K16','서울','MBC청룡', NULL),
('K17','인천','삼미슈퍼스타즈', NULL);

SELECT	TEAM_ID, TEAM_NAME, REGION_NAME, STADIUM_ID		/* 17개 팀, 그 중 2개 팀은 전용구장이 없음 */
FROM	TEAM;

SELECT	STADIUM_ID, STADIUM_NAME, SEAT_COUNT			/* 20개 경기장, 그 중 5개 경기장은 전용구장이 아님 */
FROM	STADIUM;

------------------------------

SELECT 	TEAM_ID, TEAM_NAME, REGION_NAME, TEAM.STADIUM_ID, STADIUM_NAME, SEAT_COUNT 
FROM 	TEAM JOIN STADIUM USING (STADIUM_ID)
ORDER 	BY TEAM_ID;

SELECT 	TEAM_ID, TEAM_NAME, REGION_NAME, TEAM.STADIUM_ID, STADIUM_NAME, SEAT_COUNT 
FROM 	TEAM LEFT JOIN STADIUM USING (STADIUM_ID) 
ORDER 	BY TEAM_ID;

SELECT 	TEAM_ID, TEAM_NAME, REGION_NAME, STADIUM.STADIUM_ID, STADIUM_NAME, SEAT_COUNT 
FROM 	TEAM RIGHT JOIN STADIUM USING (STADIUM_ID) 
ORDER 	BY TEAM_ID;

/* 에러: MySQL은 Full Join을 지원하지 않음 */
SELECT 	TEAM_ID, TEAM_NAME, REGION_NAME, STADIUM.STADIUM_ID, STADIUM_NAME, SEAT_COUNT 
FROM 	TEAM FULL JOIN STADIUM ON TEAM.STADIUM_ID = STADIUM.STADIUM_ID 
ORDER 	BY TEAM_ID;

SELECT 	TEAM_ID, TEAM_NAME, REGION_NAME, STADIUM.STADIUM_ID, STADIUM_NAME, SEAT_COUNT 
FROM 	TEAM LEFT JOIN STADIUM USING (STADIUM_ID) 
UNION
SELECT 	TEAM_ID, TEAM_NAME, REGION_NAME, STADIUM.STADIUM_ID, STADIUM_NAME, SEAT_COUNT 
FROM 	TEAM RIGHT JOIN STADIUM USING (STADIUM_ID) 
ORDER 	BY TEAM_ID;


-------------------------------------------
-- 3.4 CROSS JOIN (Cartesian Product)
-------------------------------------------

-- kleague DB를 초기화한 후, 아래 질의를 실행

SELECT  TEAM_ID, TEAM_NAME, TEAM.STADIUM_ID, STADIUM_NAME 
FROM 	TEAM CROSS JOIN STADIUM							/* 조인 조건 혹은 조인 애트르비튜를 사용하지 않음 */
ORDER 	BY TEAM_ID;

------------------------------
/* 출력 투플의 개수를 카운트 (아래 두 질의의 결과는 동일함) */

WITH TEMP AS
(
		SELECT  TEAM_ID, TEAM_NAME, TEAM.STADIUM_ID, STADIUM_NAME 
		FROM 	TEAM CROSS JOIN STADIUM
		ORDER 	BY TEAM_ID
)
SELECT	COUNT(*)
FROM	TEMP;

SELECT	COUNT(*) 
FROM 	(
			SELECT  TEAM_ID, TEAM_NAME, TEAM.STADIUM_ID, STADIUM_NAME 
			FROM 	TEAM CROSS JOIN STADIUM
			ORDER 	BY TEAM_ID
		) AS TEMP;

------------------------------

/* 주의: CROSS JOIN에 조인 조건 혹은 조인 애트르비튜를 사용하면, JOIN 혹은  INNER JOIN과 같은 결과임 */
SELECT  TEAM_ID, TEAM_NAME, TEAM.STADIUM_ID, STADIUM_NAME 
FROM 	TEAM CROSS JOIN STADIUM ON TEAM.STADIUM_ID = STADIUM.STADIUM_ID 
ORDER 	BY TEAM_ID;


-------------------------------------------
-- 4. DML Algebra : SELF JOIN
-------------------------------------------

USE		company;

SELECT	*
FROM	employee;

SELECT	emp.Ssn, CONCAT(emp.Fname, ' ', emp.Minit, '. ', emp.Lname) AS Employee, 
		mgr.Ssn, CONCAT(mgr.Fname, ' ', mgr.Minit, '. ', mgr.Lname) AS Manager
FROM  	employee emp JOIN employee mgr ON emp.Super_ssn=mgr.Ssn
ORDER BY mgr.Fname;
------------------------------

SELECT	CONCAT(emp.Fname, ' ', emp.Minit, '. ', emp.Lname) AS Employee, 
		CONCAT(mgr.Fname, ' ', mgr.Minit, '. ', mgr.Lname) AS Manager
FROM  	employee emp JOIN employee mgr ON emp.Super_ssn=mgr.Ssn;

SELECT	CONCAT(emp.Fname, ' ', emp.Minit, '. ', emp.Lname) AS Employee, 
		CONCAT(mgr.Fname, ' ', mgr.Minit, '. ', mgr.Lname) AS Manager
FROM  	employee emp LEFT JOIN employee mgr ON emp.Super_ssn=mgr.Ssn;

SELECT 	CONCAT(emp.Fname, ' ', emp.Minit, '. ', emp.Lname) AS Employee, 
		CONCAT(mgr.Fname, ' ', mgr.Minit, '. ', mgr.Lname) AS Manager,
        CONCAT(mgrOfMgr.Fname, ' ', mgrOfMgr.Minit, '. ', mgrOfMgr.Lname) AS ManagerOfManager
FROM	employee emp LEFT JOIN employee mgr ON emp.Super_ssn=mgr.Ssn
		LEFT JOIN employee mgrOfMgr ON mgr.Super_ssn = mgrOfMgr.Ssn;

------------------------------

-- Q: 'Franklin Wong'이 관리하는 직원

SELECT	emp.Ssn, CONCAT(emp.Fname, ', ', emp.Minit, '. ', emp.Lname) AS Employee, 
		mgr.Ssn, CONCAT(mgr.Fname, ', ', mgr.Minit, '. ', mgr.Lname) AS Manager
FROM  	employee emp JOIN employee mgr on emp.Super_ssn=mgr.ssn
where	mgr.Fname='Franklin' and mgr.Lname='Wong';

-- Q: 'Franklin Wong'의 관리자

SELECT	emp.Ssn, CONCAT(emp.Fname, ', ', emp.Minit, '. ', emp.Lname) AS Employee, 
		mgr.Ssn, CONCAT(mgr.Fname, ', ', mgr.Minit, '. ', mgr.Lname) AS Manager
FROM  	employee emp JOIN employee mgr on emp.Super_ssn=mgr.ssn
where	emp.Fname='Franklin' and emp.Lname='Wong';
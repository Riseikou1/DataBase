-- Queries for kleague Sample Database
-- Version 1.0

USE kleague;

DESCRIBE PLAYER;
DESCRIBE TEAM;
DESCRIBE STADIUM;
DESCRIBE SCHEDULE;


-------------------------------------------
-- 1. SELECT 문의 WHERE 절 서브쿼리
-------------------------------------------

-------------------------------------------
-- 1.1 비연관, 단일값 서브쿼리
-------------------------------------------

-- Q: 서브쿼리에 집계 함수를 사용

-- RETURN THE FUCKERS WHOSE HEIGHT IS BELOW AVG.

SELECT 	PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버 ,HEIGHT
FROM 	PLAYER 
WHERE 	HEIGHT <= 	(	
						SELECT	AVG(HEIGHT) 
						FROM	PLAYER 
					) 
ORDER 	BY PLAYER_NAME; 

-------------------------------------------
-- 1.2 비연관, 다중값 서브쿼리
-------------------------------------------

-- Q: ‘정현수’ 선수가 소속되어 있는 팀 정보를 검색

SELECT 	REGION_NAME 연고지명, TEAM_NAME 팀명, E_TEAM_NAME 영문팀명 
FROM 	TEAM 
WHERE 	TEAM_ID = 	(									/* 에러: 결과가 2개 이상 */
						SELECT	TEAM_ID 
						FROM	PLAYER 
						WHERE	PLAYER_NAME = '정현수'
					) 
ORDER 	BY TEAM_NAME;

/* 아래 두 질의는 동일함 */

SELECT 	REGION_NAME 연고지명, TEAM_NAME 팀명, E_TEAM_NAME 영문팀명 
FROM 	TEAM 
WHERE 	TEAM_ID = ANY 	(								/* 다중값 (scalar의 집합) */
							SELECT	TEAM_ID 
							FROM	PLAYER 
							WHERE	PLAYER_NAME = '정현수'
						) 
ORDER 	BY TEAM_NAME;

SELECT 	REGION_NAME 연고지명, TEAM_NAME 팀명, E_TEAM_NAME 영문팀명 ,TEAM_ID
FROM 	TEAM 
WHERE 	TEAM_ID IN 	(									/* 다중행 (1-tuple의 집합) */
						SELECT	TEAM_ID 
						FROM	PLAYER 
						WHERE	PLAYER_NAME = '정현수'
					) 
ORDER 	BY TEAM_NAME;


-------------------------------------------
-- 1.3 비연관, 다중행 서브쿼리
-------------------------------------------
SELECT * FROM PLAYER;
-- Q: 각 팀에서 제일 키가 작은 선수들을 검색

SELECT TEAM_ID, PLAYER_NAME, POSITION, HEIGHT
FROM (
    SELECT *, 
           RANK() OVER (PARTITION BY TEAM_ID ORDER BY HEIGHT ASC) AS rnk
    FROM PLAYER
    WHERE HEIGHT IS NOT NULL
) AS ranked
WHERE rnk = 1
ORDER BY TEAM_ID;


SELECT TEAM_ID, PLAYER_NAME, POSITION, HEIGHT
FROM PLAYER P1
WHERE P1.HEIGHT = (
	SELECT MIN(P2.HEIGHT)
    FROM PLAYER P2
    WHERE P1.TEAM_ID = P2.TEAM_ID
)
ORDER BY TEAM_ID;


SELECT	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER 
WHERE 	(TEAM_ID, HEIGHT) IN 	(						/* 다중행 (2-tuple의 집합) */
									SELECT  TEAM_ID, MIN(HEIGHT) 
									FROM	PLAYER 
									GROUP	BY TEAM_ID	
								) 
ORDER 	BY TEAM_ID, PLAYER_NAME;

-------------------------------------------
-- 1.4 연관, 단일값 서브쿼리
-------------------------------------------

-- Q: 각 팀에서 제일 키가 큰 선수를 검색. (아래 두 질의의 결과는 동일함)

SELECT	TEAM_ID, PLAYER_NAME, HEIGHT
FROM	PLAYER P1
WHERE	HEIGHT = 	(							/* 연관, 단일값 서브쿼리 */
						SELECT	MAX(HEIGHT)
						FROM	PLAYER P2
						WHERE	P2.TEAM_ID = P1.TEAM_ID		/* 연관 조건 */
					)
ORDER	BY TEAM_ID;


SELECT	TEAM_ID, PLAYER_NAME, HEIGHT
FROM	PLAYER
WHERE	(TEAM_ID, HEIGHT) IN 	(				/* 비연관, 다중행 서브쿼리 */	
									SELECT	TEAM_ID, MAX(HEIGHT)
									FROM	PLAYER
									GROUP	BY TEAM_ID
								)
ORDER	BY TEAM_ID;

-- Q: 소속 팀의 평균 키보다 작은 선수들을 검색.


SELECT	TEAM_ID, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM	PLAYER P1
WHERE	P1.HEIGHT < (	
						SELECT	AVG(P2.HEIGHT) 
						FROM	PLAYER P2
						WHERE	P2.TEAM_ID = P1.TEAM_ID
					)
ORDER	BY P1.TEAM_ID, 키 DESC, 선수명;


-------------------------------------------
-- 1.5 연관, 다중값 서브쿼리
-------------------------------------------

-- Q: 브라질 혹은 러시아 출신의 선수가 있는 팀을 검색하시오. (아래 두 질의의 결과는 동일함)

SELECT TEAM_NAME , TEAM_ID
FROM TEAM
WHERE TEAM_ID IN
	(SELECT TEAM_ID
	FROM PLAYER 
	WHERE NATION IN ('러시아','브라질')
	)
ORDER BY TEAM_NAME;


SELECT	TEAM_ID, TEAM_NAME
FROM	TEAM T
WHERE	TEAM_ID = ANY 	(						/* 연관, 다중값 서브쿼리 */
							SELECT	TEAM_ID
							FROM	PLAYER P
							WHERE	P.TEAM_ID = T.TEAM_ID AND 
									(P.NATION = '브라질' OR P.NATION = '러시아')
						);

SELECT	TEAM_ID, TEAM_NAME
FROM	TEAM T
WHERE	TEAM_ID IN 	(							/* 연관, 다중값 서브쿼리 (scalar의 집합) */
							SELECT	TEAM_ID
							FROM	PLAYER P
							WHERE	P.TEAM_ID = T.TEAM_ID AND 
									(P.NATION = '브라질' OR P.NATION = '러시아')
					);


-------------------------------------------
-- 1.6 연관, 다중행 서브쿼리
-------------------------------------------

-- Q: 20120501부터 20120502 사이에 경기가 열렸던 경기장을 조회.

SELECT	STADIUM_ID ID, STADIUM_NAME 경기장명
FROM	STADIUM ST 
WHERE	EXISTS 	(								/* 연관, 다중행 서브쿼리 (1-tuple의 집합) */
					SELECT 	1					/* 1 대신 *도 가능  */
					FROM 	SCHEDULE SC 
					WHERE	SC.STADIUM_ID = ST.STADIUM_ID AND 
							SC.SCHE_DATE BETWEEN '2012-05-01' AND '2012-05-02' 
				);

-- 참고
SELECT 	1
FROM 	SCHEDULE SC 
WHERE	SC.SCHE_DATE BETWEEN '2012-05-01' AND '2012-05-02';

SELECT 	*
FROM 	SCHEDULE SC 
WHERE	SC.SCHE_DATE BETWEEN '2012-05-01' AND '2012-05-02';


-- Q: INTERSECT 연산 - 소속이 K02 팀이면서 포지션이 GK인 선수들을 검색. (아래 두 질의의 결과는 동일함)

SELECT PLAYER_NAME , POSITION , TEAM_ID
FROM PLAYER P
WHERE TEAM_ID IN(
	SELECT TEAM_ID
    FROM TEAM T
    WHERE T.TEAM_ID = P.TEAM_ID AND TEAM_ID = 'K02'
) AND P.POSITION = 'GK'
ORDER BY TEAM_ID;


SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, 
		BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER P1
WHERE 	TEAM_ID = 'K02' AND 
		EXISTS 	(	
					SELECT 	1					/* 1 대신 *도 가능  */
					FROM 	PLAYER P2 
					WHERE 	P2.PLAYER_ID = P1.PLAYER_ID AND 
							P2.POSITION = 'GK'
				);

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, 
		BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER
WHERE 	TEAM_ID = 'K02' AND POSITION = 'GK';


-- Q: EXCEPT 연산 - 소속이 K02 팀이면서 포지션이 MF가 아닌 선수들을 검색 (아래 두 질의의 결과는 동일함)

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER P1
WHERE 	TEAM_ID = 'K02' AND 
		NOT EXISTS 	(	
						SELECT 	1 
						FROM 	PLAYER P2
						WHERE 	P2.PLAYER_ID = P1.PLAYER_ID AND POSITION = 'MF'
					);

SELECT 	TEAM_ID 팀코드, PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버, HEIGHT 키 
FROM 	PLAYER
WHERE 	TEAM_ID = 'K02' AND POSITION <> 'MF';
                        
                        
-------------------------------------------
-- Note: 조인과 연관 서브쿼리의 차이
------------------------------------------- 

SELECT	T.TEAM_NAME, P.PLAYER_NAME						/* TEAM과 PLAYER 어느 쪽의 속성도 올 수 있음 */
FROM	TEAM T JOIN PLAYER P ON T.TEAM_ID = P.TEAM_ID;	/* 최대 15x480개 투플이 생성될 수 있으나, 실제로는 480개 투플이 생성됨 */

-- SELECT THE TEAMS WHICH HAS SOME BRAZIL PLAYER(S).

SELECT distinct TEAM_NAME, T.TEAM_ID
FROM TEAM T
JOIN PLAYER P ON T.TEAM_ID = P.TEAM_ID
WHERE P.NATION = '브라질';


SELECT	TEAM_NAME
FROM	TEAM T
WHERE	TEAM_ID = ANY 	(
							SELECT	P.TEAM_ID
							FROM	PLAYER P
							WHERE	P.TEAM_ID = T.TEAM_ID AND P.NATION = '브라질'
						);


-------------------------------------------
-- 2. SELECT 문의 WHERE 절 이외의 위치에 사용된 서브쿼리
-------------------------------------------

-------------------------------------------
-- 2.1 SELECT 절 서브쿼리 (Scalar Subquery)
-------------------------------------------

-- Q: 선수 정보와 해당 선수가 속한 팀의 평균 키를 함께 검색.


SELECT 	TEAM_ID, PLAYER_NAME 선수명, HEIGHT 키, 
		(									/* 단일값 서브쿼리 */
			SELECT	ROUND(AVG(HEIGHT),2)
			FROM	PLAYER P2
			WHERE	P2.TEAM_ID = P1.TEAM_ID
		) 팀평균키
FROM	PLAYER P1
ORDER 	BY TEAM_ID;


SELECT TEAM_ID, PLAYER_NAME, HEIGHT,
       AVG(HEIGHT) OVER (PARTITION BY TEAM_ID) AS `AVERAGE HEIGHT`
FROM PLAYER
ORDER BY TEAM_ID;


-- Q: 팀명과 팀의 소속 선수수를 검색
-- RETURN TEAM_ID , TEAM_NAME , AND NUMBER OF PLAYERS OF EVERY TEAM.


SELECT 	TEAM_ID, TEAM_NAME,
		(									/* 단일값 서브쿼리 */
			SELECT	COUNT(*)
			FROM	PLAYER P
			WHERE	P.TEAM_ID = T.TEAM_ID
		) 팀인원수
FROM	TEAM T
ORDER	BY TEAM_ID;


SELECT T.TEAM_ID, T.TEAM_NAME, COUNT(P.PLAYER_ID) AS TEMUUJINGOD
FROM TEAM T
LEFT JOIN PLAYER P ON T.TEAM_ID = P.TEAM_ID
GROUP BY T.TEAM_ID, T.TEAM_NAME
ORDER BY T.TEAM_ID;


-- Q: 각 팀의 최종 경기일을 검색
-- RETURN TEAM_ID , TEAM_NAME , AND LATEST_SHIT DATE.

SELECT TEAM_ID ,TEAM_NAME , MAX(C.SCHE_DATE) AS 'LATEST COMP'
FROM TEAM T LEFT JOIN SCHEDULE C ON T.TEAM_ID = C.HOMETEAM_ID OR T.TEAM_ID = AWAYTEAM_ID
GROUP BY T.TEAM_ID , T.TEAM_NAME
ORDER BY TEAM_ID;


SELECT	TEAM_ID, TEAM_NAME, 
		(									/* 단일값 서브쿼리 */
			SELECT	MAX(SCHE_DATE)
			FROM	SCHEDULE SC
            WHERE	GUBUN = 'Y' AND 
					(SC.HOMETEAM_ID = T.TEAM_ID OR SC.AWAYTEAM_ID = T.TEAM_ID)
		) '최종 경기일'
FROM	TEAM T;

select * from TEAM

-------------------------------------------
-- 2.2 FROM 절 서브쿼리 (inline view, 혹은 dynamic view)
-------------------------------------------

-- Q: K09 팀의 선수 이름, 포지션, 백넘버를 검색 (아래 두 질의의 결과는 동일함)


SELECT	PLAYER_NAME, POSITION, BACK_NO		/* 서브쿼리 테이블의 속성을 메인쿼리에서 사용 */
FROM	(									/* 다중행 서브쿼리 */
			SELECT	TEAM_ID, PLAYER_ID, PLAYER_NAME, POSITION, BACK_NO
			FROM	PLAYER
			ORDER 	BY PLAYER_ID ASC
		) AS PLAYER_TEMP
WHERE	TEAM_ID = 'K09';

WITH PLAYER_TEMP AS
(
		SELECT	TEAM_ID, PLAYER_ID, PLAYER_NAME, POSITION, BACK_NO 
		FROM 	PLAYER 
		ORDER 	BY PLAYER_ID DESC 
)
SELECT 	PLAYER_NAME, POSITION, BACK_NO ,TEAM_ID
FROM 	PLAYER_TEMP
WHERE 	TEAM_ID = 'K09'; 

SELECT * FROM PLAYER_TEMP;					/* 에러: PLAYER_TEMP 테이블이 존재하지 않음 */
DESCRIBE PLAYER_TEMP;						/* 에러: PLAYER_TEMP 테이블이 존재하지 않음 */


-- Q: 포지션이 MF인 선수들의 소속팀명 및 선수 정보를 검색 (아래 두 질의의 결과는 동일함)


SELECT	T.TEAM_NAME 팀명, P.PLAYER_NAME 선수명, P.BACK_NO 백넘버 ,P.POSITION
FROM	(									/* 다중행 서브쿼리 */
			SELECT	TEAM_ID, PLAYER_NAME, BACK_NO,POSITION 
			FROM	PLAYER 
			WHERE	POSITION = 'MF'
		) P, TEAM T 
WHERE	P.TEAM_ID = T.TEAM_ID 
ORDER	BY 팀명, 선수명; 


WITH PLAYER_TEMP AS
(
		SELECT 	TEAM_ID, PLAYER_NAME, BACK_NO 
		FROM 	PLAYER 
		WHERE 	POSITION = 'MF'
)
SELECT 	TEAM_NAME 팀명, PLAYER_NAME 선수명, BACK_NO 백넘버 
FROM 	PLAYER_TEMP JOIN TEAM USING (TEAM_ID)
ORDER 	BY 팀명, 선수명; 

-- TEMUUJIN'S WAY TO HANDLE LIKE A PRO.
SELECT PLAYER_NAME , PLAYER_ID, POSITION , T.TEAM_ID,T.TEAM_NAME
FROM PLAYER JOIN TEAM T ON PLAYER.TEAM_ID = T.TEAM_ID
WHERE PLAYER.POSITION = 'MF'
ORDER BY TEAM_ID;


-- Q: 키가 제일 큰 5명 선수들의 정보를 검색 (top-N query)

SELECT 	PLAYER_NAME 선수명, POSITION 포지션, BACK_NO 백넘버,
		HEIGHT 키 
FROM 	(
			SELECT 	PLAYER_NAME, POSITION, BACK_NO, HEIGHT 
			FROM 	PLAYER 
			WHERE 	HEIGHT IS NOT NULL 
			ORDER 	BY HEIGHT DESC				/* 서브쿼리에 ORDER BY 절 사용 */
		) AS TEMP
LIMIT	5;

SELECT PLAYER_NAME, POSITION,BACK_NO, HEIGHT
FROM (
	SELECT *, ROW_NUMBER() OVER(ORDER BY HEIGHT DESC) AS RN
	FROM PLAYER
	WHERE HEIGHT IS NOT NULL
) AS TEMP
WHERE RN <= 5;

-------------------------------------------
-- 2.3 HAVING 절 서브쿼리
-------------------------------------------

-- Q: 평균키가 K02 (삼성 블루윙즈) 팀의 평균키보다 작은 팀의 이름과 해당 팀의 평균키를 검색


SELECT	P.TEAM_ID 팀코드, T.TEAM_NAME 팀명, AVG(P.HEIGHT) 평균키 	/* SELECT 절에서 TEAM_NAME을 출력하려면 */
FROM	PLAYER P JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID 
GROUP	BY P.TEAM_ID, T.TEAM_NAME								/* TEAM_NAME을 GROUP BY에 포함해야 함. */ 
HAVING	AVG(P.HEIGHT) < (	
							SELECT	AVG(HEIGHT) 
							FROM	PLAYER 
							WHERE	TEAM_ID ='K02' 
						);

SELECT	P.TEAM_ID 팀코드, T.TEAM_NAME 팀명, AVG(P.HEIGHT) 평균키 
FROM	PLAYER P JOIN TEAM T ON P.TEAM_ID = T.TEAM_ID 
GROUP	BY P.TEAM_ID										/* MySQL에서는 TEAM_NAME을 GROUP BY에 포함하지 않아도 됨. THDE YUR NI BOL AGGEREGATE HIIHGEEGUI BUG L ATTIBUTE-IIG GROUP BY-D ORUULAH YOSTOI BAIDAG L GEJIINLE.*/ 
HAVING	AVG(P.HEIGHT) < (	
							SELECT	AVG(HEIGHT) 
							FROM	PLAYER 
							WHERE	TEAM_ID ='K02' 
						);

 
-------------------------------------------
-- 3. 갱신문의 서브쿼리
-------------------------------------------

-------------------------------------------
-- 3.1 UPDATE 문 서브쿼리
-------------------------------------------

ALTER	TABLE	TEAM
ADD		COLUMN	STADIUM_NAME VARCHAR(40);

DESCRIBE TEAM;

SET sql_safe_updates = 0;	

UPDATE	TEAM T 
SET		T.STADIUM_NAME = 	(	
								SELECT	S.STADIUM_NAME 
								FROM	STADIUM S 
								WHERE	T.STADIUM_ID = S.STADIUM_ID
							); 
                            
SELECT	TEAM_NAME, STADIUM_ID, STADIUM_NAME
FROM	TEAM;

SET sql_safe_updates = 1;	


-------------------------------------------
-- 3.2 INSERT 문 서브쿼리
-------------------------------------------

/* 에러: MySQL에서는 같은 테이블에서 SELECT하여 INSERT/UPDATE 할 수 없음. */
INSERT	INTO	PLAYER (PLAYER_ID, PLAYER_NAME, TEAM_ID) 
VALUES	(
			(
				SELECT	MAX(PLAYER_ID) + 1 
				FROM 	PLAYER
            ), 
			'홍길동', 'K06'
		);
-- Queries for kleague Sample Database
-- Version 1.0

USE kleague;

DESCRIBE PLAYER;
DESCRIBE TEAM;
DESCRIBE STADIUM;
DESCRIBE SCHEDULE;



-------------------------------------------
-- 1. CTE와 With 절
-------------------------------------------

-------------------------------------------
-- 1.1 Non-recursive CTE
-------------------------------------------

-- Q: CTE와 WITH 절 (아래 두 질의의 결과는 동일함)


WITH TEMP AS 
(
		SELECT	TEAM_NAME, STADIUM_ID, STADIUM_NAME
		FROM 	TEAM JOIN STADIUM USING (STADIUM_ID)
)
SELECT	TEAM_NAME, STADIUM_NAME
FROM	TEMP;


SELECT	TEAM_NAME, STADIUM_NAME
FROM	(
			SELECT	TEAM_NAME, STADIUM_ID, STADIUM_NAME
			FROM 	TEAM JOIN STADIUM USING (STADIUM_ID)
		) AS TEMP;


-- Q: Multiple CTE
-- SCHEDULE 테이블에서 STADIUM_ID, HOMETEAM_ID, AWAYTEAM_ID를 
-- 각각 경기장명, 홈팀명, 어웨이팀명으로 출력하시오.

WITH SCHEDULE_TEMP1 AS 			/* 홈팀명을 갖는 SCHEDULE */   -- this shit gives us home team name
(
		SELECT 	S.STADIUM_ID, SCHE_DATE, TEAM_NAME AS HOMETEAM_NAME, AWAYTEAM_ID, 
				HOME_SCORE, AWAY_SCORE
		FROM	SCHEDULE S JOIN TEAM T ON S.HOMETEAM_ID = T.TEAM_ID
),
SCHEDULE_TEMP2 AS				/* 홈팀명, 어웨이팀명을 갖는 SCHEDULE */    -- and this shit adds away team name.
(		-- CONNECTING AWAY_TEAM NAME USING AWAY_TEAM ID THAT FIRST TABLE BROUGHT FROM SCHEDULE TABLE.
		SELECT	T1.STADIUM_ID, SCHE_DATE, HOMETEAM_NAME, TEAM_NAME AS AWAYTEAM_NAME,
				HOME_SCORE, AWAY_SCORE
		FROM	SCHEDULE_TEMP1 T1 JOIN TEAM T ON T1.AWAYTEAM_ID = T.TEAM_ID
)
SELECT	STADIUM_NAME 경기장명, SCHE_DATE, HOMETEAM_NAME 홈팀명, AWAYTEAM_NAME 어웨이팀명, 
		HOME_SCORE, AWAY_SCORE
FROM	SCHEDULE_TEMP2 T2 JOIN STADIUM S ON T2.STADIUM_ID = S.STADIUM_ID;


-------------------------------------------
-- 1.2 Recursive CTE
-------------------------------------------

-- Q: 수열 출력 (아래 두 질의의 결과는 동일함)

WITH RECURSIVE cte(n) AS 
(
	SELECT  1
	UNION	ALL
	SELECT  n + 1 FROM cte WHERE n < 5
)
SELECT 	* FROM 	cte;

-- Q: CTE와 Type casting

WITH RECURSIVE cte AS 
(
	SELECT	1 AS n, 'abc' AS str			/* 예러: str의 데이터 타입은 CHAR(3) */
	UNION	ALL
	SELECT	n + 1, CONCAT(str, str) FROM cte WHERE n < 3
)
SELECT * FROM cte;

/* recursive SELECT 문의 컬럼 타입 변환 (아래 두 질의의 결과는 동일함) */

WITH RECURSIVE cte AS 
(
	SELECT	1 AS n, CAST('abc' AS CHAR(30)) AS str
	UNION 	ALL
	SELECT	n + 1, CONCAT(str, str) FROM cte WHERE n < 4
)
SELECT	* FROM cte;

WITH RECURSIVE cte(n,str) AS 
(
	SELECT	1, CAST('abc' AS CHAR(30))
	UNION 	ALL
	SELECT	n + 1, CONCAT(str, str) FROM cte WHERE n < 4
)
SELECT	* FROM cte;


-------------------------------------------
-- 1.3 Recursive CTE의 사용 예
-------------------------------------------

-- Q: Fibonacci Series Generation


WITH RECURSIVE factorial (n,fact) AS
(
	select 1,1
    union all
    select n+1, fact * (n+1)
    from factorial
    where n < 8
)
select * from factorial;

WITH RECURSIVE fibonacci (n, fib_n, next_fib_n) AS 
(
	SELECT  1, 0, 1
	UNION  ALL
	SELECT  n + 1, next_fib_n, fib_n + next_fib_n 
	FROM   fibonacci 
	WHERE n < 10
)
SELECT 	*  FROM 	fibonacci;


-- Q: Data Series Generation

/* 출력에 몇몇 날짜가 누락되어 있음 */

SELECT 	SCHE_DATE, COUNT(*) AS NO_OF_GAMES 
FROM 	SCHEDULE
GROUP	BY SCHE_DATE 
ORDER 	BY SCHE_DATE;

/* 1단계 : 원하는 범위 내의 모든 날짜를 출력함 */

WITH RECURSIVE DATES (DATE) AS 
( 	-- casting to date the min== earliest match inthe database.
	SELECT CAST(MIN(SCHE_DATE) AS DATE) 	/* Casting 하지 않으면 에러 */
    FROM SCHEDULE		
	UNION ALL
	SELECT DATE + INTERVAL 1 DAY 
	FROM  DATES
	WHERE DATE + INTERVAL 1 DAY <= '2012-03-31'
) 
SELECT 	* 
FROM 	DATES;

/* 2단계 : Dates와 Schedule 테이블을 조인함 */

WITH RECURSIVE DATES (DATE) AS 
( 
	SELECT CAST(MIN(SCHE_DATE) AS DATE) FROM SCHEDULE		/* Casting 하지 않으면 에러 */
		UNION ALL 
	SELECT DATE + INTERVAL 1 DAY 
	FROM  DATES
	WHERE DATE + INTERVAL 1 DAY <= '2012-03-31'
) 
SELECT 	*
FROM 	DATES LEFT JOIN SCHEDULE ON DATES.DATE = SCHEDULE.SCHE_DATE 
ORDER 	BY DATES.DATE;

/* 3단계 : 최종 결과 */

WITH RECURSIVE DATES (DATE) AS 
( 
	SELECT CAST(MIN(SCHE_DATE) AS DATE) FROM SCHEDULE		/* Casting 하지 않으면 에러 */
		UNION ALL 
	SELECT DATE + INTERVAL 1 DAY 
	FROM  DATES
	WHERE DATE + INTERVAL 1 DAY <= '2012-03-31'
) 
SELECT 	DATES.DATE, COUNT(SCHE_DATE) AS NO_OF_GAMES 		/* COUNT(*)를 사용하지 않음 */
FROM 	DATES LEFT JOIN SCHEDULE ON DATES.DATE = SCHEDULE.SCHE_DATE 
GROUP	BY DATES.DATE 
ORDER 	BY DATES.DATE;


-- Q: (Hierarchical Query) 사원들을 사장부터 최하위 직급까지 직급별로 순서대로 검색

USE		company;

WITH RECURSIVE employee_anchor (Ssn, Fname, Minit, Lname, Level) AS
(
		SELECT	Ssn, Fname, Minit, Lname, 1
        FROM	employee
        WHERE	Super_ssn IS NULL 				/* 사장 */  -- means we're starting from boss.and starting from that boss,choosing its under worker.
        UNION	ALL
        SELECT	e.Ssn, e.Fname, e.Minit, e.Lname, Level+1
        FROM	employee_anchor ea join employee e ON ea.Ssn = e.Super_ssn
)
SELECT	*
FROM	employee_anchor;


-- Q: (Hierarchical Query) 'Ramesh Narayan'의 관리자부터 최상위 관리자까지 모든 관리자를 직급별로 순서대로 검색

WITH RECURSIVE employee_anchor (Ssn, Fname, Minit, Lname, Super_ssn, Level) AS
(
		SELECT	Ssn, Fname, Minit, Lname, Super_ssn, 1  
        FROM	employee
        WHERE	Fname = 'Ramesh' AND Lname = 'Narayan'		/* 말단 사원 */   -- displays only himself and his boss, boss's boss.
        UNION	ALL
        SELECT	e.Ssn, e.Fname, e.Minit, e.Lname, e.Super_ssn, Level+1
        FROM	employee_anchor ea join employee e ON ea.Super_ssn = e.Ssn
)
SELECT	*
FROM	employee_anchor;

-------------------------------------------
-- 2. Pivoting
-------------------------------------------

-- 투플 개수를 카운트하여 통계치를 구하는 경우
-- Q: 팀별/포지션별 선수수를 검색 (세로축: 팀, 가로축: 포지션)

/* Step 1: 원시 데이터 테이블에서 pivot시킬 데이터 테이블 생성 */

use kleague;
SELECT	PLAYER_NAME, TEAM_ID, POSITION
FROM	PLAYER;

/* Step 2: 피벗 컬럼을 pivot시킴 (피벗 컬럼 대신, 피벗 컬럼 값의 개수 만큼 새로운 컬럼을 생성) */

SELECT	PLAYER_NAME, TEAM_ID,
		CASE POSITION WHEN 'FW' THEN 1 END FW_temuujin,
		CASE POSITION WHEN 'MF' THEN 1 END MF,
        CASE POSITION WHEN 'DF' THEN 1 END DF,
        CASE POSITION WHEN 'GK' THEN 1 END GK,
        CASE WHEN POSITION IS NULL THEN 1 END UNDECIDED
FROM	PLAYER;   


/* Step 3: GROUP BY 절 / 집계 함수로 통계치(선수수) 생성 */

SELECT	TEAM_ID,
		COALESCE(SUM(CASE POSITION WHEN 'FW' THEN 1 END),0) FW,
		COALESCE(SUM(CASE POSITION WHEN 'MF' THEN 1 END),0) MF,
        COALESCE(SUM(CASE POSITION WHEN 'DF' THEN 1 END),0) DF,
        COALESCE(SUM(CASE POSITION WHEN 'GK' THEN 1 END),0) GK,
        COALESCE(SUM(CASE WHEN POSITION IS NULL THEN 1 END),0) UNDECIDED,
        COUNT(PLAYER_NAME) SUM
FROM	PLAYER
GROUP 	BY TEAM_ID
ORDER 	BY TEAM_ID;
    
------------------------------
-- 저장된 값의 통계치를 구하는 경우
-- Q: 팀 별로 각각의 생월(태어난 달)에 대한 선수의 평균 키를 구함 (세로축: 팀, 가로축: 생월)

/* Step 1: 원시 데이터 테이블에서 pivot시킬 데이터 테이블 생성 */

SELECT	PLAYER_NAME, TEAM_ID, BIRTH_DATE, MONTH(BIRTH_DATE) AS MONTH, HEIGHT
FROM	PLAYER;

/* Step 2: 피벗 컬럼을 pivot시킴 (피벗 컬럼 대신, 피벗 컬럼 값의 개수 만큼 새로운 컬럼을 생성) */

SELECT	PLAYER_NAME, TEAM_ID, BIRTH_DATE,
		CASE MONTH(BIRTH_DATE) WHEN 1 THEN HEIGHT END M01,
        CASE MONTH(BIRTH_DATE) WHEN 2 THEN HEIGHT END M02,
		CASE MONTH(BIRTH_DATE) WHEN 3 THEN HEIGHT END M03,
        CASE MONTH(BIRTH_DATE) WHEN 4 THEN HEIGHT END M04,
        CASE MONTH(BIRTH_DATE) WHEN 5 THEN HEIGHT END M05,
        CASE MONTH(BIRTH_DATE) WHEN 6 THEN HEIGHT END M06,
        CASE MONTH(BIRTH_DATE) WHEN 7 THEN HEIGHT END M07,
        CASE MONTH(BIRTH_DATE) WHEN 8 THEN HEIGHT END M08,
        CASE MONTH(BIRTH_DATE) WHEN 9 THEN HEIGHT END M09,
        CASE MONTH(BIRTH_DATE) WHEN 10 THEN HEIGHT END M10,
        CASE MONTH(BIRTH_DATE) WHEN 11 THEN HEIGHT END M11,
        CASE MONTH(BIRTH_DATE) WHEN 12 THEN HEIGHT END M12,
        CASE WHEN MONTH(BIRTH_DATE) IS NULL THEN HEIGHT END 생일모름
FROM	PLAYER;    

/* Step 3: GROUP BY 절 / 집계 함수로 통계치(평균키) 생성 */

SELECT	TEAM_ID, COUNT(*) AS 선수수,
		ROUND(AVG(CASE MONTH(BIRTH_DATE) WHEN 1 THEN HEIGHT END),2) M01,
        ROUND(AVG(CASE MONTH(BIRTH_DATE) WHEN 2 THEN HEIGHT END),2) M02,
		ROUND(AVG(CASE MONTH(BIRTH_DATE) WHEN 3 THEN HEIGHT END),2) M03,
        ROUND(AVG(CASE MONTH(BIRTH_DATE) WHEN 4 THEN HEIGHT END),2) M04,
        ROUND(AVG(CASE MONTH(BIRTH_DATE) WHEN 5 THEN HEIGHT END),2) M05,
        ROUND(AVG(CASE MONTH(BIRTH_DATE) WHEN 6 THEN HEIGHT END),2) M06,
        ROUND(AVG(CASE MONTH(BIRTH_DATE) WHEN 7 THEN HEIGHT END),2) M07,
        ROUND(AVG(CASE MONTH(BIRTH_DATE) WHEN 8 THEN HEIGHT END),2) M08,
        ROUND(AVG(CASE MONTH(BIRTH_DATE) WHEN 9 THEN HEIGHT END),2) M09,
        ROUND(AVG(CASE MONTH(BIRTH_DATE) WHEN 10 THEN HEIGHT END),2) M10,
        ROUND(AVG(CASE MONTH(BIRTH_DATE) WHEN 11 THEN HEIGHT END),2) M11,
        ROUND(AVG(CASE MONTH(BIRTH_DATE) WHEN 12 THEN HEIGHT END),2) M12,
        ROUND(AVG(CASE WHEN MONTH(BIRTH_DATE) IS NULL THEN HEIGHT END),2) 생일모름
FROM	PLAYER
GROUP	BY TEAM_ID;
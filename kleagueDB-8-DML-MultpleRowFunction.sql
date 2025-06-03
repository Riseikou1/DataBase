-- Queries for kleague Sample Database
-- Version 1.0

USE kleague;

DESCRIBE PLAYER;
DESCRIBE TEAM;
DESCRIBE STADIUM;
DESCRIBE SCHEDULE;


-------------------------------------------
-- 1. Window Functions 
-------------------------------------------

-- Q : raw data table

SELECT	PLAYER_NAME, POSITION, HEIGHT
FROM	PLAYER
WHERE	TEAM_ID = 'K10';						/* 36개 투플 */

-- Q : Aggregate function

SELECT	AVG(HEIGHT) AS HEIGHT_AVG				/* 전체 통계 */
FROM	PLAYER
WHERE	TEAM_ID = 'K10';

SELECT	POSITION, AVG(HEIGHT) AS HEIGHT_AVG		/* 그룹별 통계 */ 
FROM	PLAYER
WHERE	TEAM_ID = 'K10'
GROUP 	BY POSITION;

-- Q : Window function

SELECT	PLAYER_NAME, POSITION, HEIGHT,
		AVG(HEIGHT) OVER () AS HEIGHT_AVG		/* 전체에 대한 투플별 통계 */
FROM	PLAYER
WHERE	TEAM_ID = 'K10';


SELECT	PLAYER_NAME, POSITION, HEIGHT,			/* 파티션에 대한 투플별 통계 */
		AVG(HEIGHT) OVER (PARTITION BY POSITION) AS HEIGHT_AVG
FROM	PLAYER
WHERE	TEAM_ID = 'K10';


-- Note : PARTITION BY / ORDER BY / ROWS | RANGE 절을 생략해도 괄호(())는 반드시 사용함.

SELECT	PLAYER_NAME, POSITION, HEIGHT,
		AVG(HEIGHT) OVER () AS HEIGHT_AVG		/* 윈도우 함수 */
FROM	PLAYER
WHERE	TEAM_ID = 'K10';

SELECT	AVG(HEIGHT) AS HEIGHT_AVG	      		/* 집계 함수 (PLAYER_NAME, POSITION, HEIGHT는 사용 불가) */
FROM	PLAYER
WHERE	TEAM_ID = 'K10';


-------------------------------------------
-- 1.1 순위 함수
-------------------------------------------

-------------------------------------------
-- 1.1.1 ROW_NUMBER() 함수
-------------------------------------------

-- Q : 선수들의 키 순서대로 일련번호를 출력. 단, 키가 같은 경우는 이름의 오름차순으로 정렬함. 

SELECT 	PLAYER_NAME, HEIGHT,
		ROW_NUMBER() OVER (ORDER BY HEIGHT DESC, PLAYER_NAME) AS ROW_NUM
FROM 	PLAYER
WHERE	TEAM_ID = 'K06' AND POSITION = 'MF';

-------------------------------------------
-- 1.1.2 RANK() 함수
-------------------------------------------

-- Q : 선수들의 키 순서대로 순위를 출력 (동점자 처리). 단, 키가 같은 경우는 이름의 오름차순으로 정렬함. 

SELECT 	ROW_NUMBER() OVER (ORDER BY HEIGHT DESC, PLAYER_NAME ASC) AS ROW_NUM,
		PLAYER_NAME, HEIGHT,
		RANK() OVER (ORDER BY HEIGHT DESC) AS ALL_RANK
FROM 	PLAYER
WHERE	TEAM_ID = 'K06' AND POSITION = 'MF';

-- Q : 선수들의 포지션 별로, 키 순서대로 순위를 출력 (동점자 처리). 단, 키가 같은 경우는 이름의 오름차순으로 정렬함. 
-- ROW_NUM ,PLAYER_NAME, POSITION, HEIGHT, AND RANK OF HEIGHT, AND RANK OF HEIGHT CORESSPONDING TO ITS POSITION.
SELECT 	ROW_NUMBER() OVER (ORDER BY POSITION, HEIGHT DESC, PLAYER_NAME) AS ROW_NUM,
		PLAYER_NAME, POSITION, HEIGHT,
		RANK() OVER (ORDER BY HEIGHT DESC) AS ALL_RANK,
        RANK() OVER (PARTITION BY POSITION ORDER BY HEIGHT DESC) AS POSITION_RANK
FROM 	PLAYER
WHERE	TEAM_ID = 'K06'
ORDER 	BY ROW_NUM;


-------------------------------------------
-- 1.1.3 DENSE_RANK() 함수
-------------------------------------------

-- Q : 선수들의 키 순서대로 순위를 출력 (동점자 처리). 
--     단, 순위는 갭 없이 이어지고, 키가 같은 경우는 이름의 오름차순으로 정렬함. 


SELECT 	ROW_NUMBER() OVER (ORDER BY HEIGHT DESC, PLAYER_NAME) AS ROW_NUM,
		PLAYER_NAME, HEIGHT,
		DENSE_RANK() OVER (ORDER BY HEIGHT DESC) AS ALL_RANK    -- THIS WON'T SKIP RANKS WHEN THEY'RE TIED. 
        -- ENGIIN RANK NI BOL 4,4,4,7 GEJ RANK SHAANA. NEG SDA NI BOL , 4,4,4,5 L GEJ RANKING.
FROM 	PLAYER
WHERE	TEAM_ID = 'K06' AND POSITION = 'MF';


-------------------------------------------
-- Note: Top-N Query
-------------------------------------------

-- Q : K04 팀에서 포지션 별로 키가 큰 5 명씩 검색. 단, 키가 같은 경우는 이름의 오름차순으로 정렬함. (상위 5위가 아님)

WITH TEMP AS
(
	SELECT 	PLAYER_NAME, POSITION, HEIGHT,TEAM_ID,
			ROW_NUMBER() OVER 
            (
				PARTITION BY POSITION 
                ORDER BY HEIGHT DESC, PLAYER_NAME ASC
			) AS POSITION_ROW_NUM		/* 컬럼 별칭 */
	FROM 	TEAM JOIN PLAYER USING (TEAM_ID)
	WHERE	TEAM_ID = 'K04' 
)
SELECT	PLAYER_NAME,TEAM_ID, POSITION, HEIGHT, POSITION_ROW_NUM
FROM	TEMP
WHERE	POSITION_ROW_NUM <= 5;			/* 컬럼 별칭이 아나라 일반 컬럼 */


-- Q : K04 팀에서 포지션 별로 상위 5위까지 검색. 단, 키가 같은 경우는 이름의 오름차순으로 정렬함. (동점자 처리)

WITH TEMP AS
(
	SELECT 	PLAYER_NAME, POSITION, HEIGHT,
			ROW_NUMBER() OVER 
            (
				PARTITION BY POSITION 
                ORDER BY HEIGHT DESC, PLAYER_NAME ASC
			) AS POSITION_ROW_NUM,
			RANK() OVER 
            (
				PARTITION BY POSITION 
                ORDER BY HEIGHT DESC
			) AS POSITION_RANK			/* 컬럼 별칭 */
	FROM 	PLAYER
	WHERE	TEAM_ID = 'K04' 
)
SELECT	PLAYER_NAME, POSITION, HEIGHT, POSITION_ROW_NUM, POSITION_RANK
FROM	TEMP
WHERE	POSITION_RANK <= 5;				/* 컬럼 별칭이 아나라 일반 컬럼 */


-------------------------------------------
-- 1.2 집계 함수
-------------------------------------------

-------------------------------------------
-- 1.2.1 SUM() 함수
-------------------------------------------

-- Q : 팀별로 홈경기 점수의 함을 구하여, 각 경기의 정보(팀명, 경기날짜, 구분, 홈경기 점수)와 함께 출력하세요.

SELECT	TEAM_NAME, SCHE_DATE, GUBUN, HOME_SCORE,
		SUM(HOME_SCORE) OVER (PARTITION BY TEAM_ID) AS HOME_SCORE_SUM
FROM	TEAM JOIN SCHEDULE ON TEAM.TEAM_ID = SCHEDULE.HOMETEAM_ID
WHERE	GUBUN = 'Y' AND TEAM_ID <= 'K03';

------------------------------

-- Q : 팀별로 홈경기 점수의 함을 구하여, 각 경기의 정보(팀명, 경기날짜, 구분, 홈경기 점수)와 함께 출력하세요.
--     단, 홈경기 점수의 합은 경기를 홈경기 점수의 오름차순으로 정렬하여, 팀 경기의 처음부터 현재 경기까지의 "누적 합"을 구하세요.

/* 아래 두 질의는 동일함 */
-- K03 BAGIIN, TEMTSEENII RUNNING SCORE_SUM IIG SHAA.
SELECT	TEAM_NAME, SCHE_DATE, GUBUN, HOME_SCORE,TEAM_ID,
		SUM(HOME_SCORE) OVER 	( -- TRYING TO CALCULATE THE RUNNING TOTAL OF HOME_SCORE PER TEAM.
									PARTITION BY TEAM_ID
                                    ORDER BY SCHE_DATE
									-- ORDER BY HOME_SCORE 
									RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW  --  Start from the lowest score and add up to the current one.
								) AS HOME_SCORE_SUM
FROM	TEAM JOIN SCHEDULE ON TEAM.TEAM_ID = SCHEDULE.HOMETEAM_ID
WHERE	GUBUN = 'Y' AND TEAM_ID <= 'K03';


SELECT	TEAM_NAME, SCHE_DATE, GUBUN, HOME_SCORE,
		SUM(HOME_SCORE) OVER 	(
									PARTITION BY TEAM_ID 
                                    ORDER BY SCHE_DATE
                                    RANGE UNBOUNDED PRECEDING
								) AS HOME_SCORE_SUM
FROM	TEAM JOIN SCHEDULE ON TEAM.TEAM_ID = SCHEDULE.HOMETEAM_ID
WHERE	GUBUN = 'Y' AND TEAM_ID <= 'K03';


-------------------------------------------
-- Note : 정렬 기준 컬럼 (ORDER BY 절) 값이 동일한 행에서, RANGE 절과 ROWS 절의 차이
-------------------------------------------

/* RANGE 절에서 “1”은  현재 행의 HOME_SCORE 값에 “1”을 빼거나 더하는 것을 의미함. */

SELECT	TEAM_NAME, SCHE_DATE, GUBUN, HOME_SCORE,
		SUM(HOME_SCORE) OVER 	(
									PARTITION BY TEAM_ID 
									ORDER BY HOME_SCORE
									RANGE BETWEEN 1 PRECEDING AND 1 FOLLOWING
								) AS HOME_SCORE_SUM
FROM	TEAM JOIN SCHEDULE ON TEAM.TEAM_ID = SCHEDULE.HOMETEAM_ID
WHERE	GUBUN = 'Y' AND TEAM_ID <= 'K03';

/* ROWS 절에서 “1”은 한 개 행을 의미함. 즉, 현재 행의 하나 앞과 하나 뒤 행을 의미함. */

SELECT	TEAM_NAME, SCHE_DATE, GUBUN, HOME_SCORE,
		SUM(HOME_SCORE) OVER 	(
									PARTITION BY TEAM_ID 
									ORDER BY SCHE_DATE
									ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
								) AS HOME_SCORE_SUM
FROM	TEAM JOIN SCHEDULE ON TEAM.TEAM_ID = SCHEDULE.HOMETEAM_ID
WHERE	GUBUN = 'Y' AND TEAM_ID <= 'K03';


-------------------------------------------
-- 1.2.2 AVG() 함수
-------------------------------------------

-- Q : 각 경기의 정보(팀명, 경기날짜, 구분, 홈경기 점수)를 홈팀의 평균 점수와 함께 출력하세요.
--     단, 홈팀의 평균 점수는, 그 팀이 홈 팀으로 참여한 모든 경기의 홈 점수를 합하여 계산합니다.

SELECT	TEAM_NAME, SCHE_DATE, GUBUN, HOME_SCORE,
		AVG(HOME_SCORE) OVER 	(
									PARTITION BY TEAM_ID 
                                    RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
								) AS HOME_SCORE_AVG
FROM	TEAM JOIN SCHEDULE ON TEAM.TEAM_ID = SCHEDULE.HOMETEAM_ID
WHERE	GUBUN = 'Y' AND TEAM_ID <= 'K03';


-- Q : 각 경기의 정보(팀명, 경기날짜, 구분, 홈경기 점수)를 홈팀의 평균 점수와 함께 출력하세요.
--     단, 홈팀의 평균 점수는, 홈팀 점수를 오름차순으로 정렬한 후, 첫번째 행부터 현재 행까지의 홈 점수를 합하여 계산합니다.

SELECT	TEAM_NAME,TEAM_ID, SCHE_DATE, GUBUN, HOME_SCORE,
		AVG(HOME_SCORE) OVER 	(
									PARTITION BY TEAM_ID 
                                    ORDER BY HOME_SCORE 
                                    RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
								) AS HOME_SCORE_AVG
FROM	TEAM JOIN SCHEDULE ON TEAM.TEAM_ID = SCHEDULE.HOMETEAM_ID
WHERE	GUBUN = 'Y' AND TEAM_ID <= 'K03';


-- Q : 각 경기의 정보(팀명, 경기날짜, 구분, 홈경기 점수)를 홈팀의 평균 점수와 함께 출력하세요.
--     단, 홈팀의 평균 점수는, 홈팀 점수를 오름차순으로 정렬한 후, 현재 행의 바로 앞과 뒤의 1개 행의 홈 점수를 합하여 계산합니다.

SELECT	TEAM_NAME,TEAM_ID, SCHE_DATE, GUBUN, HOME_SCORE,
		AVG(HOME_SCORE) OVER 	(
									PARTITION BY TEAM_ID 
                                    ORDER BY HOME_SCORE 
                                    ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
								) AS HOME_SCORE_AVG
FROM	TEAM JOIN SCHEDULE ON TEAM.TEAM_ID = SCHEDULE.HOMETEAM_ID
WHERE	GUBUN = 'Y' AND TEAM_ID <= 'K03';


-------------------------------------------
-- 1.2.3 MAX() 함수
-------------------------------------------

-- Q : 팀별로 홈경기 점수의 최고치를 구하여, 각 경기의 정보(팀명, 경기날짜, 구분, 홈경기 점수)와 함께 출력하세요.

SELECT	TEAM_NAME,TEAM_ID, SCHE_DATE, GUBUN, HOME_SCORE,
		MAX(HOME_SCORE) OVER (PARTITION BY TEAM_ID) AS HOME_SCORE_MAX
FROM	TEAM JOIN SCHEDULE ON TEAM.TEAM_ID = SCHEDULE.HOMETEAM_ID
WHERE	GUBUN = 'Y' AND TEAM_ID <= 'K03';


-- Q : 팀별로 홈경기 점수가 최고인 경기의 정보(팀명, 경기날짜, 구분, 홈경기 점수)를 홈경기 최고 점수와 함께 출력하세요.

WITH TEMP AS
(
		SELECT	TEAM_NAME,TEAM_ID, SCHE_DATE, GUBUN, HOME_SCORE,
				MAX(HOME_SCORE) OVER (PARTITION BY TEAM_ID) AS HOME_SCORE_MAX
		FROM	TEAM JOIN SCHEDULE ON TEAM.TEAM_ID = SCHEDULE.HOMETEAM_ID
		WHERE	GUBUN = 'Y' AND TEAM_ID <= 'K03'
)
SELECT	TEAM_NAME,TEAM_ID, SCHE_DATE, GUBUN, HOME_SCORE
FROM	TEMP
WHERE	HOME_SCORE = HOME_SCORE_MAX;


-------------------------------------------
-- 1.2.4 COUNT() 함수
-------------------------------------------

-- Q : 선수를 키의 오름차순으로 정렬한 후, 선수의 이름과 키, 그리고 그 선수의 키에 2를 빼고 더한 값의 범위에 있는 선수의 수를 출력하시오.

SELECT	PLAYER_NAME, HEIGHT,
		COUNT(*) OVER	(
							ORDER BY HEIGHT 
							RANGE BETWEEN 2 PRECEDING AND 2 FOLLOWING
						) AS CNT,
		CONCAT(HEIGHT - 2, '~', HEIGHT + 2) AS 범위
FROM	PLAYER
WHERE	TEAM_ID = 'K06' AND POSITION = 'FW';


-------------------------------------------
-- 1.3 그룹 내 행 순서 관련 함수
-------------------------------------------

-------------------------------------------
-- 1.3.1 FIRST_VALUE() 함수와 LAST_VALUE() 함수
-------------------------------------------

-- Q : 포지션 별로 키가 제일 큰 선수의 이름을 구하여, 모든 선수에 대해 선수 정보(포지션, 선수명, 키)와 함께 출력하세요.
-- PRINT THE NAME OF THE PLAYER WHO IS THE TALLEST PLAYER OF THE POSITION OF THAT EACH PLAYER SHIT, IN THE LAST COLUM.
SELECT	POSITION, PLAYER_NAME, HEIGHT,
		FIRST_VALUE(PLAYER_NAME) OVER	(
							PARTITION BY POSITION
                            ORDER BY HEIGHT DESC
							ROWS UNBOUNDED PRECEDING
						) AS TALLIST_PLAYER
FROM	PLAYER
WHERE	TEAM_ID = 'K06';


-- Q : 포지션 별로 키가 제일 작은 선수의 이름을 구하여, 모든 선수에 대해 선수 정보(포지션, 선수명, 키)와 함께 출력하세요.

SELECT	POSITION, PLAYER_NAME, HEIGHT,
		LAST_VALUE(PLAYER_NAME) OVER	(
							PARTITION BY POSITION
                            ORDER BY HEIGHT DESC 
							RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW -- UNBOUNDED NTR GEESHAAHAARA,ZUGEER L ENENEES NAMHAN SDA GARJ IRTEL L PRINT HIIGEED SHAAY L GESEN UG BAIH IN.
						) AS SMALLAST_PLAYER
FROM	PLAYER
WHERE	TEAM_ID = 'K06';


-- 위의 예에서 프레임 정의만 변경 : ROWS 절과 RANGE 절의 차이 파악

SELECT	POSITION, PLAYER_NAME, HEIGHT,
		LAST_VALUE(PLAYER_NAME) OVER	(
							PARTITION BY POSITION
                            ORDER BY HEIGHT DESC 
							ROWS UNBOUNDED PRECEDING  /* ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW */
						) AS SMALLIST_PLAYER
FROM	PLAYER
WHERE	TEAM_ID = 'K06';


-------------------------------------------
-- 1.3.2 LAG() 함수와 LEAD() 함수
-------------------------------------------

-- Q : K06 팀의 GK 포지션 선수들을 키의 내림차순으로 정렬하고, 선수의 이름과 키, 그리고 자기 앞 행의 키를 함께 출력하세요.

/* 아래 두 질의는 동일함 */

SELECT	PLAYER_NAME, HEIGHT,
		LAG(HEIGHT) OVER (ORDER BY HEIGHT DESC) AS PREV_HEIGHT
FROM	PLAYER
WHERE	TEAM_ID = 'K06' AND POSITION = 'GK';

SELECT	PLAYER_NAME, HEIGHT,
		LAG(HEIGHT,1) OVER (ORDER BY HEIGHT DESC) AS PREV_HEIGHT
FROM	PLAYER
WHERE	TEAM_ID = 'K06' AND POSITION = 'GK';

------------------------------

-- Q : K06 팀의 GK 포지션 선수들을 키의 내림차순으로 정렬하고, 선수의 이름과 키, 그리고 자기 두번째 앞 행의 키를 함께 출력하세요.

SELECT	PLAYER_NAME, HEIGHT,
		LAG(HEIGHT,2,99999) OVER (ORDER BY HEIGHT DESC) AS PREV_HEIGHT
FROM	PLAYER
WHERE	TEAM_ID = 'K06' AND POSITION = 'GK';

------------------------------

-- Q : K06 팀의 GK 포지션 선수들을 키의 내림차순으로 정렬하고, 선수의 이름과 키, 그리고 자기 뒤 행의 키를 함께 출력하세요.

SELECT	PLAYER_NAME, HEIGHT,
		LEAD(HEIGHT) OVER (ORDER BY HEIGHT DESC) AS NEXT_HEIGHT
FROM	PLAYER
WHERE	TEAM_ID = 'K06' AND POSITION = 'GK';

-- LEAD CAN ALSO HAVE STEP SIZE AND DEFAULT FALL BACK VALUE ---> SAME AS LAG.
SELECT	PLAYER_NAME, HEIGHT,
		LEAD(HEIGHT,1,99999989) OVER (ORDER BY HEIGHT DESC) AS NEXT_HEIGHT
FROM	PLAYER
WHERE	TEAM_ID = 'K06' AND POSITION = 'GK';


-------------------------------------------
-- 1.4 그룹 내 비율 관련 함수
-------------------------------------------

SELECT	RANK() OVER (ORDER BY HEIGHT DESC) AS RNK,
		PLAYER_NAME, HEIGHT,
		ROUND(PERCENT_RANK() OVER	(
                            ORDER BY HEIGHT DESC 
						),2) AS PER_RANK
FROM	PLAYER
WHERE	TEAM_ID = 'K04' AND POSITION = 'MF';
 

SELECT	ROW_NUMBER() OVER (ORDER BY HEIGHT DESC) AS ROW_NUM,
		PLAYER_NAME, HEIGHT,
		ROUND(CUME_DIST() OVER	(
                            ORDER BY HEIGHT DESC 
						),2) AS CUME_DISTRIBUTION
FROM	PLAYER
WHERE	TEAM_ID = 'K04' AND POSITION = 'MF';


SELECT	ROW_NUMBER() OVER (ORDER BY HEIGHT DESC) AS ROW_NUM,
		PLAYER_NAME, HEIGHT,
		NTILE(3) OVER	(
                            ORDER BY HEIGHT DESC 
						) AS TILE_NUM
FROM	PLAYER
WHERE	TEAM_ID = 'K04' AND POSITION = 'MF';


SELECT	ROW_NUMBER() OVER (ORDER BY HEIGHT DESC) AS ROW_NUM,
		PLAYER_NAME, HEIGHT,
		RATIO_TO_REPORT(HEIGHT) OVER () AS RATIO_REPORT
FROM	PLAYER
WHERE	TEAM_ID = 'K04' AND POSITION = 'MF';			/* 에러: RATIO_TO_REPORT() 함수는 MySQL에서 제공하지 않음 */


-------------------------------------------
-- 2. Group Functions
-------------------------------------------

-------------------------------------------
-- 2.1 WITH ROLLUP 절
-------------------------------------------

-- Q: GROUP BY

SELECT 	TEAM_NAME, POSITION, COUNT(*) 'Total Players', AVG(HEIGHT) 'Average Height' 
FROM 	TEAM JOIN PLAYER USING (TEAM_ID)
WHERE	TEAM_ID <= 'K03'
GROUP 	BY TEAM_NAME, POSITION;


-- Q: 팀 별, 그리고 팀의 포지션 별로 선수의 수와 평균 키를 검색 (GROUP BY + WITH ROLLUP)

/* 아래 두 질의는 동일함 */

SELECT 	TEAM_NAME, POSITION, COUNT(*) 'Total Players', AVG(HEIGHT) 'Average Height' 
FROM 	TEAM JOIN PLAYER USING (TEAM_ID)
WHERE	TEAM_ID <= 'K03'
GROUP 	BY TEAM_NAME, POSITION WITH ROLLUP;

SELECT 	TEAM_NAME, POSITION, COUNT(*) 'Total Players', AVG(HEIGHT) 'Average Height' 
FROM 	TEAM JOIN PLAYER USING (TEAM_ID)
WHERE	TEAM_ID <= 'K03'
GROUP 	BY TEAM_NAME, POSITION
UNION ALL
SELECT 	TEAM_NAME, NULL, COUNT(*) 'Total Players', AVG(HEIGHT) 'Average Height' 
FROM 	TEAM JOIN PLAYER USING (TEAM_ID)
WHERE	TEAM_ID <= 'K03'
GROUP 	BY TEAM_NAME
UNION ALL
SELECT 	NULL, NULL, COUNT(*) 'Total Players', AVG(HEIGHT) 'Average Height' 
FROM 	TEAM JOIN PLAYER USING (TEAM_ID)
WHERE	TEAM_ID <= 'K03'
ORDER 	BY TEAM_NAME DESC;


-- Q: 팀의 포지션별과 팀별로 선수의 수와 평균 키를 검색 (소계와 총계의 레이블을 사용)

/* step 1 */

SELECT 	TEAM_NAME, GROUPING(TEAM_NAME), 
		POSITION, GROUPING(POSITION), 
        COUNT(*) 'Total Players', AVG(HEIGHT) 'Average Height' 
FROM 	TEAM JOIN PLAYER USING (TEAM_ID)
WHERE	TEAM_ID <= 'K03'
GROUP 	BY TEAM_NAME, POSITION WITH ROLLUP;

/* step 2 */

SELECT 	CASE 	GROUPING(TEAM_NAME)
				WHEN 1	THEN 'All Teams'
						ELSE TEAM_NAME
		END AS 'Team Name',
		CASE	GROUPING(POSITION)
				WHEN 1	THEN 'All Positions'
						ELSE POSITION
		END AS Position,
        COUNT(*) 'Total Players', AVG(HEIGHT) 'Average Height' 
FROM 	TEAM JOIN PLAYER USING (TEAM_ID)
WHERE	TEAM_ID <= 'K03'
GROUP 	BY TEAM_NAME, POSITION WITH ROLLUP;


-------------------------------------------
-- 2.2 CUBE 함수
-------------------------------------------

SELECT 	CASE 	GROUPING(TEAM_NAME)
				WHEN 1	THEN 'All Teams'
						ELSE TEAM_NAME
		END AS 'Team Name',
		CASE	GROUPING(POSITION)
				WHEN 1	THEN 'All Positions'
						ELSE POSITION
		END AS Position,
        COUNT(*) 'Total Players', AVG(HEIGHT) 'Average Height' 
FROM 	TEAM JOIN PLAYER USING (TEAM_ID)
WHERE	TEAM_ID <= 'K03'
GROUP 	BY CUBE(TEAM_NAME, POSITION);			/* 에러: CUBE() 함수는 MySQL에서 제공하지 않음 */
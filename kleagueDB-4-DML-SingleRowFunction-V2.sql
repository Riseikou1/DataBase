-- Queries for kleague Sample Database
-- Version 1.0

USE kleague;

DESCRIBE PLAYER;
DESCRIBE TEAM;
DESCRIBE STADIUM;
DESCRIBE SCHEDULE;


-------------------------------------------
-- 1. 문자형 내장함수
-------------------------------------------

SELECT 	LENGTH('SQL Expert') AS ColumnLength; 

SELECT 	PLAYER_ID, CONCAT(PLAYER_NAME, ' 선수') AS 선수명 
FROM 	PLAYER;

SELECT	STADIUM_NAME, TEL, SUBSTR(TEL, 1, INSTR(TEL, '-') - 1) AS 국번호
FROM	STADIUM;	


-------------------------------------------
-- 2. 숫자형 내장함수
-------------------------------------------

SELECT 	ROUND(SUM(HEIGHT)/COUNT(HEIGHT),3) AS '평균키(소수 넷째자리 반올림)', 
		TRUNCATE(SUM(HEIGHT)/COUNT(HEIGHT),3) AS '평균키(소수 넷째자리 버림)'
FROM 	PLAYER;


-------------------------------------------
-- 3. 날짜형 내장함수
-------------------------------------------

/* 날짜형 함수 출력 시에는 컨텍스트에 따라 문자형 혹은 숫자형으로 출력 */

SELECT 	NOW();			/* 디폴트는 문자형 */ 
 
SELECT 	NOW() + 0;		/* 컨텍스트에 따라 숫자형 */ 

-----------------------------

SELECT 	SYSDATE() AS CurrentTime;		/* 현재 시간 */
SELECT 	NOW() AS CurrentTime;			/* 명령어가 실행된 시작 시간 */


SELECT 	SYSDATE(), SLEEP(5), SYSDATE();	/* 현재 시간 */
SELECT 	NOW(), SLEEP(5), NOW();			/* SELECT 명령어가 실행된 시작 시간 */

-----------------------------

CREATE TABLE movie ( 
	id 			INT 			PRIMARY KEY AUTO_INCREMENT, 	/* surrogate */
	title 		VARCHAR(255) 	NOT NULL, 
	created_on 	DATETIME 		NOT NULL DEFAULT NOW() 		/* 투플이 삽입된 시간(INSERT 문이 실해된 시간)을 기록 */
); 

INSERT INTO movie (title)
VALUES		('Top Gun');

INSERT INTO movie (title)
VALUES		('Money Ball');

SELECT	*
FROM	movie;

-----------------------------

SELECT 	TIMESTAMP(NOW()) AS CurrentTimestamp,	/* 날짜형 - DATETIME */
		DATE(NOW()) AS CurrentDate,				/* 날짜형 - DATE */
		YEAR(NOW()) AS Year, 					/* 숫자형 - SMALLINT */
		MONTH(NOW()) AS Month, 					/* 숫자형 - TINYINT */
        DAY(NOW()) AS Day,						/* 숫자형 - TINYINT */
        MONTHNAME(NOW()) AS MonthName,			/* 문자형 - TINYTEXT */
        DAYNAME(NOW()) AS DayName,				/* 문자형 - TINYTEXT */
        WEEKDAY(NOW()) AS WeekIndex,			/* 숫자형 - TINYINT */
		TIME(NOW()) AS CurrentTime,				/* 날짜형 - TIME */
        HOUR(NOW()) AS Hour,					/* 숫자형 - TINYINT */
        MINUTE(NOW()) AS Minute,				/* 숫자형 - TINYINT */
        SECOND(NOW()) AS Second;				/* 숫자형 - TINYINT */

-----------------------------
/* 두 개의 날짜형 (DATE, TIME, DATETIME) 컬럼 혹은 값을 직접 더하거나 빼지 않아야 함. */
/* 컨텍스트에 의해, 산술 연산으로 해석함. 즉, 날짜를 문자열이 아닌 숫자로 변환하여 계산함. */

SELECT	DATE('2024-12-26') - DATE('2024-12-22') AS diff;	/* 20241226 - 20241222 = 4 */
SELECT	DATE('2024-12-26') - DATE('2024-10-22') AS diff;	/* 20241226 - 20241022 = 204 */

-----------------------------
/* INTERVAL 표현식은 숫자를 날짜형으로 변환함 */

SELECT	DATE('2024-12-26') + 7 AS diff;					/* 20241233, 숫자형(INT) + 숫자형(INT) */
SELECT	DATE('2024-12-26') + INTERVAL 7 DAY AS diff;	/* 2025-01-02, 날짜형(DATE) + 날짜형(DATE) */


SELECT	TIME('12:25:37') - INTERVAL 2 HOUR AS diff;		/* 10:25:37, 날짜형(TIME) + 날짜형(TIME) */
SELECT	TIME('12:25:37') - INTERVAL 30 MINUTE AS diff;	/* 11:55:37, 날짜형(TIME) + 날짜형(TIME) */

SELECT	NOW() AS 현재시간,
		DATE(NOW()) + INTERVAL 1 YEAR AS 테스트1,
		DATE(NOW()) + INTERVAL 2 MONTH AS 테스트2,
		DATE(NOW()) + INTERVAL 3 DAY AS 테스트3,
		TIME(NOW()) + INTERVAL 1 HOUR AS 테스트4,
        TIME(NOW()) + INTERVAL 2 MINUTE AS 테스트5,
        TIME(NOW()) + INTERVAL 3 SECOND AS 테스트5;

-----------------------------

SELECT	TIMESTAMPDIFF(DAY, '2024-12-22', '2024-12-26') AS diff;		/* 4 */
SELECT	TIMESTAMPDIFF(DAY, '2024-10-22', '2024-12-26') AS diff;		/* 65 */

SELECT	YEAR('2020-05-15') - YEAR('2000-08-02'), 
		TIMESTAMPDIFF(YEAR, '2000-08-02', '2020-05-15');

SELECT	PLAYER_NAME AS 선수명, BIRTH_DATE AS 생일,
		TIMESTAMPDIFF(YEAR, BIRTH_DATE, DATE(NOW())) AS 나이,		/* 만나이 계산 */
        FLOOR(DATEDIFF(DATE(NOW()), BIRTH_DATE) / 365) AS 나이
FROM	PLAYER;


-----------------------------

SELECT	PLAYER_NAME, 
		DATE_FORMAT(BIRTH_DATE, '%Y-%m-%d'),
		DATE_FORMAT(BIRTH_DATE, '%D %M %Y')
FROM	PLAYER;

SELECT 	DATE_FORMAT('2003-03-31', GET_FORMAT(DATE, 'ISO')) AS ISO, 
		DATE_FORMAT('2003-03-31', GET_FORMAT(DATE, 'JIS')) AS JIS,
		DATE_FORMAT('2003-03-31', GET_FORMAT(DATE, 'USA')) AS USA, 
		DATE_FORMAT('2003-03-31', GET_FORMAT(DATE, 'EUR')) AS EUR, 
		DATE_FORMAT('2003-03-31', GET_FORMAT(DATE, 'INTERNAL')) AS INTERNAL; 

SELECT	PLAYER_NAME, POSITION,
		DATE_FORMAT(BIRTH_DATE, GET_FORMAT(DATE, 'ISO')) BIRTH_DATE
FROM	PLAYER;

-----------------------------

SELECT	STR_TO_DATE('21,5,2013', '%d,%m,%Y');	/* 2013-05-21 */
SELECT	STR_TO_DATE('2013', '%Y');				/* 2013-00-00 */
SELECT	STR_TO_DATE('113005', '%h%i%s');		/* 11:30:05 */
SELECT	STR_TO_DATE('11', '%h');				/* 11:00:00 */
SELECT	STR_TO_DATE('20130101 1130', '%Y%m%d %h%i');	/* 2013-01-01 11:30:00*/
SELECT	STR_TO_DATE('21,5,2013 extra characters', '%d,%m,%Y');	/* 2013-05-21 */


-------------------------------------------
-- 4. 변환형 내장함수
-------------------------------------------

SELECT	CONCAT('Date: ', CAST(NOW() AS DATE));

SELECT 	TEAM_ID, ZIP_CODE1, ZIP_CODE2,
		CONCAT(ZIP_CODE1, '-', ZIP_CODE2) AS 우편번호,
		CAST(ZIP_CODE1 AS UNSIGNED) + CAST(ZIP_CODE2 AS UNSIGNED) 우편번호합 
FROM 	TEAM;

-----------------------------

SELECT	CONVERT(NOW(), DATE);


-------------------------------------------
-- 5. NULL 관련 함수
-------------------------------------------

-- COALESCE() 함수

SELECT	COALESCE(NULL, 1);

SELECT	COALESCE(NULL, NULL, NULL);

-- RETURN  TEAM 'K08'S PLAYER_NAME , POSITION , HEIGHT. IF POS IS NULL RETURN '*****' , HEIGHT -> 0;

SELECT	PLAYER_NAME, 
		COALESCE(POSITION, '*****') AS POSITION, 	/* 문자형 데이타가 널일 때, '*****'로 대치 */
		COALESCE(HEIGHT, 0) AS HEIGHT				/* 숫자형 데이타가 널일 때, 0으로 대치 */
FROM	PLAYER
WHERE	TEAM_ID = 'K08';


-----------------------------
/* 아래 두 질의의 결과는 동일함 */
/* COALESCE() 함수는 중첩된 CASE 절로 표현 가능함 */

-- RETURN E_PLAYER_NAME AS TEMUUJIN IF THERE ISNT ANY, RETURN NICKNAME INSTEAD.

SELECT	PLAYER_NAME, E_PLAYER_NAME, NICKNAME, 
		COALESCE(E_PLAYER_NAME, NICKNAME) AS 별칭
FROM	PLAYER;

SELECT	PLAYER_NAME, E_PLAYER_NAME, NICKNAME,
		CASE	
				WHEN 	E_PLAYER_NAME IS NOT NULL 	THEN E_PLAYER_NAME
                ELSE	(
						CASE	
								WHEN NICKNAME IS NOT NULL	THEN NICKNAME
								ELSE NULL
						END) 
		END AS 별칭
FROM	PLAYER;



-----------------------------
/* NULL 값과의 수치 계산은 NULL을 리턴함 */
 
SELECT	PLAYER_ID, PLAYER_NAME, HEIGHT, WEIGHT, (HEIGHT * 10) + WEIGHT
FROM	PLAYER;

SELECT	PLAYER_ID, PLAYER_NAME, HEIGHT, WEIGHT, 
		(HEIGHT * 10) + WEIGHT AS TEST1, 
        (HEIGHT * 10) + COALESCE(WEIGHT,0) AS TEST2,
        (COALESCE(HEIGHT,0) * 10) + WEIGHT AS TEST3,
        (COALESCE(HEIGHT,0) * 10) + COALESCE(WEIGHT,0) AS TEST4
FROM	PLAYER;

-----------------------------
/* COALESCE() 함수에 인자를 3개 이상 사용하는 경우 */

-- PRINT COCTACT_TEMU. RETURN HOMEPAGE .IF THAT IS NULL, TEL. IF TEL IS NULL, ADDRESS, IF ALL OF THEM ARE NULL -> THEN JUST 'THERE IS NOT CONTACT.'

SELECT	TEAM_NAME, COALESCE(HOMEPAGE, TEL, ADDRESS, "연락처 없음") AS 연락처
FROM	TEAM;


-- NULLIF() 함수

-- IF TEAM'S  ORIG_YYYY IS 1983 ->  NULLIFY IT. 

SELECT	TEAM_NAME, ORIG_YYYY, NULLIF(ORIG_YYYY, 1983) AS NULLIF_1983
FROM	TEAM;

SELECT	TEAM_NAME, ORIG_YYYY, 
		CASE	
				WHEN ORIG_YYYY = '1983'		THEN NULL
                ELSE ORIG_YYYY
		END AS NULLIF_1983
FROM	TEAM;


-----------------------------
/* NULL 관련 비표준 함수 */

-- IFNULL() 함수 (COALESCE() 함수와 동일한 MySQL의 비표준 함수임)

SELECT	PLAYER_NAME, 
		IFNULL(POSITION, '*****') AS POSITION,
		IFNULL(HEIGHT, 0) AS HEIGHT
FROM	PLAYER
WHERE	TEAM_ID = 'K08';


-- ISNULL() 함수 (IS NULL 연산자를 함수로 표현한 것)
/* 아래 두 질의의 결과는 동일함 */

SELECT 	PLAYER_NAME 선수명, POSITION, 
		CASE 	
				WHEN ISNULL(POSITION)	THEN '없음'
				ELSE POSITION 
		END AS 포지션 
FROM 	PLAYER 
WHERE 	TEAM_ID = 'K08';

SELECT 	PLAYER_NAME 선수명, POSITION, 
		CASE 	
				WHEN POSITION IS NULL	THEN '없음'
				ELSE POSITION 
		END AS 포지션 
FROM 	PLAYER 
WHERE 	TEAM_ID = 'K08';

-------------------------------------------
-- 6. 논리 제어 함수와 CASE 절
-------------------------------------------

-- Searched case expression & Simple case expression

SELECT	PLAYER_NAME,
		CASE	
				WHEN POSITION = 'FW'	THEN 'Forward'
                WHEN POSITION = 'DF'	THEN 'Defense'
                WHEN POSITION = 'MF'	THEN 'Mid-field'
                WHEN POSITION = 'GK'	THEN 'Goal keeper'
                ELSE 'Undefined'
		END AS 포지션
FROM 	PLAYER;


SELECT	PLAYER_NAME,
		CASE	POSITION
				WHEN 'FW'	THEN 'Forward'
                WHEN 'DF'	THEN 'Defense'
                WHEN 'MF'	THEN 'Mid-field'
                WHEN 'GK'	THEN 'Goal keeper'
                ELSE 'Undefined'
		END AS 포지션
FROM 	PLAYER;


-- case 절의 중첩

SELECT	PLAYER_NAME, HEIGHT,
		CASE
				WHEN    HEIGHT >= 185		THEN 'A'
				ELSE 	(
							CASE
									WHEN HEIGHT >= 175		THEN 'B'
									WHEN HEIGHT < 175		THEN 'C'
									WHEN HEIGHT IS NULL		THEN 'Undecided'
							END
                        )
		END AS '신장 그룹'
FROM	PLAYER;


-- IF() 함수

SELECT	PLAYER_NAME,
		IF(POSITION = 'FW', 'Forward', 
			IF(POSITION = 'DF', 'Defense', 
				IF(POSITION = 'MF', 'Mid-field', 
					IF(POSITION = 'GK', 'Goal keeper', 'Undefined')
				)
			)
		) AS 포지션
FROM 	PLAYER;

SELECT	PLAYER_NAME,
		CASE	POSITION
				WHEN 'FW'	THEN 'Forward'
                WHEN 'DF'	THEN 'Defense'
                WHEN 'MF'	THEN 'Mid-field'
                WHEN 'GK'	THEN 'Goal keeper'
                ELSE 'Undefined'
		END AS 포지션
FROM 	PLAYER;
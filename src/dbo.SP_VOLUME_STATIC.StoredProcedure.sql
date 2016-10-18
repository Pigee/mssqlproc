USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_VOLUME_STATIC]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_VOLUME_STATIC]
@ORG_NO VARCHAR(20),
@YEAR_INT INT,
@MONTH_INT INT
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'

DECLARE @QUERY_STR VARCHAR(2000)


IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='#temp_debthis')
 DROP TABLE #temp_debthis;
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='#temp_areano')
 DROP TABLE #temp_areano;

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='#temp_time')
 DROP TABLE #temp_time;

-------------------------生成统计数据------------------------------
 -- SELECT WATERP_QAN,WATERS_QAN,VOLUME_NO, WATERM_STAT INTO #TEMP_DEBTHIS FROM FH_WATERUSED WHERE WATERU_YEAR = @YEAR_INT AND WATERU_MONTH = @MONTH_INT AND AREA_NO = @ORG_NO;
  SELECT USERB_KH,WATERP_QAN,VOLUME_NO,WATERM_STAT,WATERS_QAN,PAY_TAG,RECORD_DATE,USERB_SQDS,USERB_BQDS  INTO #temp_debthis FROM FH_DEBTLIST where debtl_year = @YEAR_INT and debtl_mon = @month_INT  AND CHANGE_RATETAG = @ORG_NO;
      
IF (YEAR(GETDATE()) <> @YEAR_INT OR MONTH(GETDATE()) <> @MONTH_INT)
  BEGIN
     -- INSERT INTO #TEMP_DEBTHIS SELECT WATERP_QAN,WATERS_QAN,VOLUME_NO,WATERM_STAT  FROM FH_WATERUSEDHIS WHERE HIS_YEAR = @YEAR_INT AND HIS_MONTH = @MONTH_INT AND AREA_NO = @ORG_NO;
      INSERT INTO #temp_debthis SELECT USERB_KH,WATERP_QAN,VOLUME_NO,WATERM_STAT,WATERS_QAN,PAY_TAG,RECORD_DATE,USERB_SQDS,USERB_BQDS  FROM  FH_DEBTOWNHIS where debtl_year = @YEAR_INT and debtl_mon = @month_INT AND CHANGE_RATETAG = @ORG_NO;
      
      SET @QUERY_STR = 'INSERT INTO #temp_debthis SELECT USERB_KH,WATERP_QAN,VOLUME_NO,WATERM_STAT,WATERS_QAN,PAY_TAG,RECORD_DATE,USERB_SQDS,USERB_BQDS  FROM FH_DEBTHIS'+CAST(@YEAR_INT AS VARCHAR)+' WHERE  CHANGE_RATETAG = '''+@ORG_NO+''' AND DEBTL_MON = '+CAST(@MONTH_INT AS VARCHAR);
      
      EXEC (@QUERY_STR);
 
  END



--select * from #temp_debthis where pay_tag ='2' and volume_no = '0801';  
 

SELECT
						VOLUME_NO,
						DATEDIFF(MINUTE,MIN(RECORD_DATE),MAX(RECORD_DATE)) CBSJ INTO #temp_time
						FROM
						#TEMP_DEBTHIS
						 GROUP BY VOLUME_NO;

-----------------输出-------------------------------

        SELECT
						t1.VOLUME_NO,
						T1.VOLUME_NAME ORG_NAME,
						t1.ZKHS,
						ISNULL(T3.SCHS,'')SCHS,
						ISNULL(T4.GCHS,'')GCHS,
						ISNULL(T5.MSHS,'')MSHS,
            ISNULL(T15.LDHS,'')LDHS,
						ISNULL(T6.HBHS,'')HBHS,
						ISNULL(T7.YSSL,'')YSSL,
						ISNULL(T8.SSSL,'')SSSL,
						CAST (
						CAST (T3.SCHS*100 AS FLOAT) / CAST(NULLIF(T1.ZKHS,0) AS FLOAT) AS DECIMAL (10, 2)
						) AS SCL,
						CAST (
						CAST (T8.SSSL*100  AS FLOAT) / CAST(NULLIF(T7.YSSL,0) AS FLOAT) AS DECIMAL (10,2)
						) AS SSL,
            t10.CBSJ
						FROM
						(
						SELECT M.VOLUME_NO,N.VOLUME_NAME,COUNT(*) ZKHS FROM FH_USERBASE M,(SELECT VOLUME_NO,VOLUME_NAME FROM FH_VOLUME WHERE AREA_NO = @ORG_NO)N WHERE M.VOLUME_no = N.VOLUME_NO GROUP BY M.VOLUME_NO,N.VOLUME_NAME) T1
						LEFT JOIN (
						SELECT
						VOLUME_NO,
						COUNT (*) SCHS
						   FROM #TEMP_DEBTHIS 
						   WHERE WATERP_QAN > 0 AND WATERM_STAT in ('sbbk26','sbbk27','sbbk28','sbbk25') AND (WATERS_QAN = 0 
						   OR WATERS_QAN IS NULL) 	GROUP BY
						VOLUME_NO
						) T3 ON T1.VOLUME_NO = T3.VOLUME_NO
						LEFT JOIN (
						SELECT
						VOLUME_NO,
						COUNT (*) GCHS
						   FROM #TEMP_DEBTHIS 
						   WHERE WATERP_QAN > 0 AND WATERM_STAT NOT in ('sbbk26','sbbk27','sbbk28','sbbk25') AND (WATERS_QAN = 0 
						   OR WATERS_QAN IS NULL) 	GROUP BY
						VOLUME_NO
						) T4 ON T1.VOLUME_NO = T4.VOLUME_NO
						LEFT JOIN (
						SELECT
						VOLUME_NO,
						COUNT (*) MSHS
						   FROM #TEMP_DEBTHIS 
						   WHERE WATERP_QAN = 0 AND USERB_SQDS <> 0 GROUP BY
						VOLUME_NO
						) T5 ON T1.VOLUME_NO = T5.VOLUME_NO
          LEFT JOIN (
						SELECT
						VOLUME_NO,
						COUNT (*) LDHS
						   FROM #TEMP_DEBTHIS 
						   WHERE WATERP_QAN = 0 AND USERB_SQDS = 0 AND USERB_BQDS = 0 GROUP BY
						VOLUME_NO
						) T15 ON T1.VOLUME_NO = T15.VOLUME_NO
						LEFT JOIN (
						SELECT
						VOLUME_NO,
						COUNT (*) HBHS
						   FROM #TEMP_DEBTHIS 
						   WHERE WATERS_QAN > 0 GROUP BY
						VOLUME_NO
						) T6 ON T1.VOLUME_NO = T6.VOLUME_NO
						LEFT JOIN (
						SELECT
						VOLUME_NO,
						SUM (WATERP_QAN) YSSL
						FROM
						#TEMP_DEBTHIS
						GROUP BY
						VOLUME_NO
						) T7 ON T1.VOLUME_NO = T7.VOLUME_NO
						 LEFT JOIN (
						SELECT
						VOLUME_NO,
						SUM (WATERP_QAN) SSSL
						FROM
						#TEMP_DEBTHIS WHERE PAY_TAG = '2'
						 GROUP BY VOLUME_NO
 ) t8 on T1.VOLUME_NO = T8.VOLUME_NO
	 LEFT JOIN (
						SELECT
						VOLUME_NO,
						DATEDIFF(MINUTE,MIN(RECORD_DATE),MAX(RECORD_DATE)) CBSJ
						FROM
						#TEMP_DEBTHIS
						 GROUP BY VOLUME_NO
 ) t10 on T1.VOLUME_NO = T10.VOLUME_NO

UNION ALL 
 SELECT '合计','',t9.ZKHS,
						T9.SCHS,
						T9.GCHS,
						T9.MSHS,
            T9.LDHS,
						T9.HBHS,
						T9.YSSL,
						T9.SSSL, 
            CAST(CAST(T9.SCHS*100 AS FLOAT)/CAST(NULLIF(T9.ZKHS,0) AS FLOAT) AS DECIMAL (10, 2)) SCL,
            CAST(CAST(T9.SSSL*100 AS FLOAT)/CAST(NULLIF(T9.YSSL,0) AS FLOAT) AS DECIMAL (10, 2)) SSL,
            T9.CBSJ FROM 
(SELECT 
(SELECT COUNT(*) FROM FH_USERBASE WHERE VOLUME_no IN (SELECT VOLUME_NO FROM FH_VOLUME WHERE AREA_NO = @ORG_NO)) ZKHS,
(SELECT COUNT (*) FROM #temp_debthis WHERE WATERP_QAN > 0 AND WATERM_STAT in ('sbbk26','sbbk27','sbbk28','sbbk25') AND (WATERS_QAN = 0 OR WATERS_QAN IS NULL) )SCHS,
(SELECT	COUNT (*) FROM #TEMP_DEBTHIS WHERE WATERP_QAN > 0 AND WATERM_STAT NOT in ('sbbk26','sbbk27','sbbk28','sbbk25') AND (WATERS_QAN = 0 OR WATERS_QAN IS NULL) )GCHS,
(SELECT COUNT (*) FROM #TEMP_DEBTHIS WHERE WATERP_QAN = 0 AND USERB_SQDS <> 0 )MSHS,
(SELECT COUNT (*) FROM #TEMP_DEBTHIS WHERE WATERP_QAN = 0 AND USERB_SQDS = 0 AND USERB_BQDS = 0  )LDHS,
(SELECT COUNT (*) FROM #TEMP_DEBTHIS WHERE WATERS_QAN > 0)HBHS,
(SELECT SUM (WATERP_QAN) FROM #TEMP_DEBTHIS) YSSL,
(SELECT SUM (WATERP_QAN) FROM #TEMP_DEBTHIS WHERE PAY_TAG = '2') SSSL,
  (SELECT SUM(CBSJ) FROM #temp_time) CBSJ
				) T9


END
GO

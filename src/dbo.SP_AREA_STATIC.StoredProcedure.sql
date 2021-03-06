USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_AREA_STATIC]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_AREA_STATIC]
@ORG_SUPER_NO VARCHAR(20),
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

-------------------------生成统计数据------------------------------
  -- SELECT WATERP_QAN,WATERS_QAN,AREA_NO, WATERM_STAT INTO #temp_debthis FROM FH_WATERUSED WHERE WATERU_YEAR = @YEAR_INT AND WATERU_MONTH = @MONTH_INT;
  SELECT WATERP_QAN,CHANGE_RATETAG,WATERM_STAT,WATERS_QAN,PAY_TAG,RECORD_DATE,USERB_SQDS,USERB_BQDS   INTO #temp_debthis FROM FH_DEBTLIST where debtl_year = @YEAR_INT and debtl_mon = @month_INT;
      
IF YEAR(GETDATE()) <> @YEAR_INT OR MONTH(GETDATE()) <> @MONTH_INT
  BEGIN
      --INSERT INTO #temp_debthis SELECT WATERP_QAN,WATERS_QAN,AREA_NO,WATERM_STAT  FROM FH_WATERUSEDHIS WHERE HIS_YEAR = @YEAR_INT AND HIS_MONTH = @MONTH_INT;
      INSERT INTO #temp_debthis SELECT WATERP_QAN,CHANGE_RATETAG,WATERM_STAT,WATERS_QAN,PAY_TAG,RECORD_DATE,USERB_SQDS,USERB_BQDS   FROM  FH_DEBTOWNHIS where debtl_year = @YEAR_INT and debtl_mon = @month_INT;
      SET @QUERY_STR = 'INSERT INTO #temp_debthis SELECT WATERP_QAN,CHANGE_RATETAG,WATERM_STAT,WATERS_QAN,PAY_TAG,RECORD_DATE,USERB_SQDS,USERB_BQDS   FROM FH_DEBTHIS'+CAST(@YEAR_INT AS VARCHAR)+' WHERE DEBTL_MON = '+CAST(@MONTH_INT AS VARCHAR);
      EXEC (@QUERY_STR);
 
  END
-------------------------
SELECT ORG_NO INTO #temp_areano FROM FH_ORG WHERE ORG_TYPE = '3' AND ORG_NO LIKE 'A00%' and len(org_no) = 5;
-----------------------
------------------------------清除多余的数据------------------------
IF @ORG_SUPER_NO IS NOT NULL 
  BEGIN
      --DELETE FROM #temp_debthis WHERE AREA_NO NOT IN ( SELECT ORG_NO FROM FH_ORG WHERE ORG_SUPER_NO = @ORG_SUPER_NO);
      DELETE FROM #temp_debthis  WHERE CHANGE_RATETAG NOT IN ( SELECT ORG_NO FROM FH_ORG WHERE ORG_SUPER_NO = @ORG_SUPER_NO);
      DELETE FROM #temp_areano WHERE ORG_NO NOT IN ( SELECT ORG_NO FROM FH_ORG WHERE ORG_SUPER_NO = @ORG_SUPER_NO);
         
  END

 IF @ORG_NO IS NOT NULL 
       BEGIN
                 -- DELETE FROM #temp_debthis WHERE AREA_NO <> @ORG_NO;
                  DELETE FROM #temp_debthis  WHERE CHANGE_RATETAG <>  @ORG_NO;
                  DELETE FROM #temp_areano WHERE ORG_NO <>  @ORG_NO;
      
       END

-- select * from #temp_debthis;

-----------------输出-------------------------------
        SELECT
						t1.AREA_NO,
						T2.ORG_NAME,
						t1.ZKHS,
						ISNULL(T3.SCHS,'')SCHS,
						ISNULL(T4.GCHS,'')GCHS,
						ISNULL(T5.MSHS,'')MSHS,
            ISNULL(T15.LDHS,'')LDHS,
						ISNULL(T6.HBHS,'')HBHS,
						ISNULL(T7.YSSL,'')YSSL,
						ISNULL(T8.SSSL,'')SSSL,
						ISNULL(CAST (
						CAST (T3.SCHS * 100 AS FLOAT) / T1.ZKHS AS DECIMAL (10, 2)
						),0) AS SCL,
						ISNULL(CAST 
						(CAST (T8.SSSL * 100 AS FLOAT) / T7.YSSL AS DECIMAL (10, 2)
						),0) AS SSL
						FROM
						(
            select CHANGE_RATETAG area_no ,count(*) zkhs from  #temp_debthis group by CHANGE_RATETAG
						-- select m.area_No,count(n.userb_kh) zkhs from fh_volume m,fh_userbase n where m.volume_No = n.volume_no and m.area_no in (select org_no from #temp_areano)group by area_No
						) T1
						LEFT JOIN FH_ORG T2 ON T1.area_No = T2.ORG_NO
						LEFT JOIN (
						SELECT
						CHANGE_RATETAG ,
						COUNT (*) SCHS
						   FROM #temp_debthis 
						   WHERE WATERP_QAN > 0 AND WATERM_STAT in ('sbbk26','sbbk27','sbbk28') AND (WATERS_QAN = 0 
						   OR WATERS_QAN IS NULL) 	GROUP BY
						CHANGE_RATETAG
						) T3 ON T1.AREA_NO = T3.CHANGE_RATETAG 
						LEFT JOIN (
						SELECT
						CHANGE_RATETAG,
						COUNT (*) GCHS
						   FROM #temp_debthis 
						   WHERE WATERP_QAN > 0 AND WATERM_STAT NOT in ('sbbk26','sbbk27','sbbk28','sbbk25') AND (WATERS_QAN = 0 
						   OR WATERS_QAN IS NULL )	GROUP BY
						CHANGE_RATETAG
						) T4 ON T1.AREA_NO = T4.CHANGE_RATETAG 
						LEFT JOIN (
						SELECT
						CHANGE_RATETAG,
						COUNT (*) MSHS
						   FROM #temp_debthis 
						   WHERE WATERP_QAN = 0 AND USERB_SQDS <> 0	GROUP BY
						CHANGE_RATETAG
						) T5 ON T1.AREA_NO = T5.CHANGE_RATETAG
           LEFT JOIN (
						SELECT
						CHANGE_RATETAG,
						COUNT (*) LDHS
						   FROM #TEMP_DEBTHIS 
						   WHERE WATERP_QAN = 0 AND USERB_SQDS = 0 AND USERB_BQDS = 0 GROUP BY
						CHANGE_RATETAG
						) T15 ON T1.AREA_NO = T15.CHANGE_RATETAG
						LEFT JOIN (
						SELECT
						CHANGE_RATETAG,
						COUNT (*) HBHS
						   FROM #temp_debthis 
						   WHERE WATERM_STAT = 'sbbk25'  GROUP BY
						CHANGE_RATETAG
						) T6 ON T1.AREA_NO = T6.CHANGE_RATETAG 
						LEFT JOIN (
						SELECT
						CHANGE_RATETAG,
						SUM (WATERP_QAN) YSSL
						FROM
						#temp_debthis
            WHERE WATERP_QAN > 0
						GROUP BY
						CHANGE_RATETAG
						) T7 ON T1.AREA_NO = T7.CHANGE_RATETAG
						 LEFT JOIN (
						SELECT
						CHANGE_RATETAG,
						SUM (WATERP_QAN) SSSL
						FROM
						#TEMP_DEBTHIS
             WHERE PAY_TAG = '2'
						 GROUP BY CHANGE_RATETAG
 ) t8 on T1.AREA_NO = T8.CHANGE_RATETAG
UNION ALL
SELECT 'A9999','合计',t9.ZKHS,
						T9.SCHS,
						T9.GCHS,
						T9.MSHS,
            T9.LDHS,
						T9.HBHS,
						ISNULL(T9.YSSL,0),
						ISNULL(T9.SSSL,0), 
            ISNULL(CAST(CAST(T9.SCHS*100 AS FLOAT)/CAST(CASE WHEN T9.ZKHS = 0 THEN NULL ELSE T9.ZKHS END AS FLOAT) AS DECIMAL (10, 2)),0) SCL,
            ISNULL(CAST(CAST(T9.SSSL*100 AS FLOAT)/CAST(CASE WHEN T9.YSSL = 0 THEN NULL ELSE T9.YSSL END AS FLOAT) AS DECIMAL (10, 2)),0) SSL FROM (SELECT 
(select count(n.userb_kh) from fh_volume m,fh_userbase n where m.volume_No = n.volume_no and m.area_no in (select org_no from #temp_areano)) ZKHS,
(SELECT COUNT (*) FROM #temp_debthis WHERE WATERP_QAN > 0 AND WATERM_STAT in ('sbbk26','sbbk27','sbbk28') AND (WATERS_QAN = 0 OR WATERS_QAN IS NULL) )SCHS,
(SELECT	COUNT (*) FROM #temp_debthis WHERE WATERP_QAN > 0 AND WATERM_STAT NOT in ('sbbk26','sbbk27','sbbk28') AND (WATERS_QAN = 0 OR WATERS_QAN IS NULL) )GCHS,
(SELECT COUNT (*) FROM #temp_debthis WHERE WATERP_QAN = 0 AND USERB_SQDS <> 0 )MSHS,
(SELECT COUNT (*) FROM #TEMP_DEBTHIS WHERE WATERP_QAN = 0 AND USERB_SQDS = 0 AND USERB_BQDS = 0 )LDHS,
(SELECT COUNT (*) FROM #temp_debthis WHERE WATERS_QAN > 0)HBHS,
(SELECT SUM (WATERP_QAN) FROM #TEMP_DEBTHIS)YSSL,
(SELECT SUM (WATERP_QAN) FROM #TEMP_DEBTHIS WHERE PAY_TAG = '2' )SSSL) T9 
END
GO

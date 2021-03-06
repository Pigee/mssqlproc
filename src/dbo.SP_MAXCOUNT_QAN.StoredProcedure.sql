USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_MAXCOUNT_QAN]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_MAXCOUNT_QAN]
@START_DATE VARCHAR(20),--'2016-01'
@END_DATE VARCHAR(20),--'2016-05'
@VOLUME_NO VARCHAR(20),-- '4001'
@PARA_QAN INT,-- 起始最大水量的最小值
@RATIO FLOAT, --0.34
@rowrn INT,-- 行数
@pagrn INT -- 页数
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='#TEMP_COUNTQAN')
 DROP TABLE #TEMP_COUNTQAN;

SELECT USERB_KH,USERB_HM,VOLUME_NO,COUNT_QAN INTO #TEMP_COUNTQAN FROM FH_WATERUSEDHIS WHERE RECORD_DATE >= CAST(@START_DATE+'-01' AS DATETIME) AND RECORD_DATE <= CAST(@END_DATE+'-25' AS DATETIME)
UNION ALL 
SELECT USERB_KH,USERB_HM,VOLUME_NO,COUNT_QAN FROM FH_WATERUSED WHERE RECORD_DATE >= CAST(@START_DATE+'-01' AS DATETIME) AND RECORD_DATE <= CAST(@END_DATE+'-25' AS DATETIME);

----------------------数据清理----------------
IF @VOLUME_NO IS NOT NULL
  BEGIN
       DELETE FROM #TEMP_COUNTQAN WHERE VOLUME_NO <> @VOLUME_NO;
  END

DELETE FROM #TEMP_COUNTQAN WHERE USERB_KH IN (SELECT M.USERB_KH FROM (SELECT USERB_KH,MAX(COUNT_QAN) MAX_CQ FROM #TEMP_COUNTQAN GROUP BY USERB_KH) M WHERE M.MAX_CQ < @PARA_QAN);

----------------------输出结果-------------------

WITH TEMP_RATIO AS (
SELECT  row_number() OVER (ORDER BY t2.userb_hm) AS rn,t2.userb_hm,t1.userb_kh,t3.waterm_no,t1.userb_addr,t2.MAX_CQ,T2.MIN_CQ,T2.ratio from  (
SELECT
  USERB_HM,
	USERB_KH,
	MAX (COUNT_QAN) MAX_CQ,
	MIN (COUNT_QAN) MIN_CQ,
	cast(CAST (
		MAX (COUNT_QAN) - MIN (COUNT_QAN) AS FLOAT
	) / CAST (MAX(COUNT_QAN) AS FLOAT) as decimal(10,4)) ratio
FROM
	#TEMP_COUNTQAN 
GROUP BY
	USERB_KH,USERB_HM) t2  left join
 fh_userbase t1  on t1.userb_kh = t2.userb_kh
left join FH_WATERMETER  t3 on t1.userb_kh = t3.userb_kh 
 where t2.ratio >= @RATIO)
SELECT rn,userb_hm,userb_kh,waterm_no,userb_addr,MAX_CQ,MIN_CQ,ratio*100 ratio FROM TEMP_RATIO WHERE rn >= (@pagrn-1)*@rowrn and rn <= (@pagrn-1)*@rowrn+@rowrn UNION ALL
select ISNULL(max(rn),0)RN,null,null,null,null,null,null,9999 from TEMP_RATIO 
order by ratio*100 ASC;

-- select top 20 * from TEMP_RATIO where userb_hm not in ( select top 20*5 userb_hm from test order by userb_hm) order by ratio




END
GO

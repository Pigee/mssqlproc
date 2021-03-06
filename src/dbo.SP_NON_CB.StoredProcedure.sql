USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_NON_CB]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_NON_CB]
@VO_NO VARCHAR(20), --  册号 或者 ’ALL‘
@START_DATE DATETIME,-- 起始年月(包含)2016-07-01
@END_DATE DATETIME,-- 截至日期(不包含)2016-10-01
@c_count int,-- 未抄次数以上显示
@row_min int,-- 从第几条开始
@row_max int,-- 到第几条开始
@TOTAL  VARCHAR(20)--求总数
-- @ROW_C VARCHAR(20),--  显示多少条纪录
-- @ROW_F VARCHAR(20)-- 从第几条开始显示
AS
DECLARE @QUERY_STR NVARCHAR(2000)
BEGIN

  -- 未抄表用户统计
  -- SELECT 'Navicat for SQL Server'

------------------------------查询所有册号-----------------------------
IF @VO_NO = 'ALL' and @TOTAL='RS'
begin 

WITH TEMP_T AS (SELECT
        USERB_KH id,
        convert(varchar(7),record_date,120) aval
    FROM
        fh_waterusedhis
    WHERE
        record_date >= @START_DATE
    AND record_date <= @END_DATE
and (wateru_qan IS NULL OR wateru_qan = 0 )) 
select  d.* from (
SELECT
		 row_number () OVER (ORDER BY a.id) AS rownumber, b.userb_hm,a.id USERB_KH,b.volume_no,c.waterm_no,b.userb_addr,a.val,a.e_count
FROM
	(
select  id, [val]=stuff((  
select ','+[aval] from TEMP_T as b where b.id = a.id for xml path('')),1,1,''),count(*) e_count from TEMP_T as a  
 group by id) A left join FH_USERBASE b on  a.id = b.userb_kh left join  FH_WATERMETER c on  a.id = c.userb_kh  
where a.e_count > @c_count and c.WATERM_ENABLED = '1' )d where d.rownumber >= @row_min and d.rownumber <= @row_max
ORDER BY
	d.rownumber ASC

END

if @TOTAL = 'TOTAL' and @VO_NO = 'ALL'
begin
select count(id) total from (
SELECT
       count(USERB_KH) as id
        --convert(varchar(7),record_date,120) aval
    FROM
        fh_waterusedhis
    WHERE
         record_date >= @START_DATE
    AND record_date <= @END_DATE
and (wateru_qan IS NULL OR wateru_qan = 0)
 GROUP BY USERB_KH
)d
where id>=@c_count
END
if @TOTAL = 'TOTAL' and @VO_NO <> 'ALL'
begin
select count(id) total from (
SELECT
       count(USERB_KH) as id
        --convert(varchar(7),record_date,120) aval
    FROM
        fh_waterusedhis
    WHERE
         record_date >= @START_DATE
    AND record_date <= @END_DATE
    AND  VOLUME_NO = @VO_NO
and (wateru_qan IS NULL OR wateru_qan = 0)
 GROUP BY USERB_KH
)d
where id>=@c_count
END
   ELSE 
BEGIN
WITH TEMP_T AS (SELECT
        USERB_KH id,
        convert(varchar(7),record_date,120) aval
    FROM
        fh_waterusedhis
    WHERE
        record_date >= @START_DATE
    AND record_date <= @END_DATE
and (wateru_qan IS NULL OR wateru_qan = 0 ) AND VOLUME_NO = @VO_NO) 
select  d.* from (
SELECT
		 row_number () OVER (ORDER BY a.id) AS rownumber, b.userb_hm,a.id USERB_KH,b.volume_no,c.waterm_no,b.userb_addr,a.val,a.e_count
FROM
	(
select id, [val]=stuff((  
select ','+[aval] from TEMP_T as b where b.id = a.id for xml path('')),1,1,''),count(*) e_count from TEMP_T as a  
 group by id) A left join FH_USERBASE b on  a.id = b.userb_kh left join  FH_WATERMETER c on  a.id = c.userb_kh  
where a.e_count > @c_count and c.WATERM_ENABLED = '1' )d where d.rownumber >= @row_min and d.rownumber <= @row_max
ORDER BY
	d.rownumber ASC
END
------------------------------------查询给定册号--------------------------------------

--SELECT * FROM #TEMP_EMPTY;
END
GO

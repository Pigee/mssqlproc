USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_WATERATE]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_WATERATE]
@VO_NO VARCHAR(36),
@PARA_YEAR INT,
@PARA_MONTH INT
AS
DECLARE @UB_KH VARCHAR(36);
DECLARE @THREE1 FLOAT;
DECLARE @THREE2 FLOAT; 
DECLARE @LASTY1 FLOAT; 
DECLARE @LASTY2 FLOAT;
DECLARE @LASTD1 FLOAT;
DECLARE @LASTD2 FLOAT;

DECLARE  CUR_KH cursor FOR SELECT USERB_KH FROM FH_USERBASE WHERE VOLUME_NO = @VO_NO FOR READ ONLY;
BEGIN
-- SELECT COUNT(*) INTO @U_CO FROM FH_USERBASE WHERE VOLOME_NO = @VO_NO

IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='#temp_waterate')
 DROP TABLE #temp_waterate;

SELECT * INTO #temp_waterate FROM FH_WATERUSEDHIS WHERE VOLUME_NO = @VO_NO AND convert(datetime,CAST(HIS_YEAR AS VARCHAR)+'-'+CAST(HIS_MONTH AS VARCHAR)+'-1') >= DATEADD(month,-3,convert(datetime,CAST(@PARA_YEAR AS VARCHAR)+'-'+CAST(@PARA_MONTH AS VARCHAR)+'-1'));

insert into #temp_waterate select * from FH_WATERUSEDHIS where VOLUME_NO = @VO_NO AND convert(datetime,CAST(HIS_YEAR AS VARCHAR)+'-'+CAST(HIS_MONTH AS VARCHAR)+'-1') = DATEADD(year,-1,convert(datetime,CAST(@PARA_YEAR AS VARCHAR)+'-'+CAST(@PARA_MONTH AS VARCHAR)+'-1'))
-------------------------------------
--select * from #temp_waterate;

OPEN CUR_KH 
fetch next from CUR_KH INTO @UB_KH
 WHILE (@@fetch_status=0)
      BEGIN
 --------------------------------------------------------------------------------
               update fh_waterused set THREEMON_AVG = (select avg(t.COUNT_QAN) from (select top 3 COUNT_QAN from #temp_waterate where userb_kh = @UB_KH order by 
       convert(datetime,CAST(HIS_YEAR AS VARCHAR)+'-'+CAST(HIS_MONTH AS VARCHAR)+'-1') desc)t) where userb_kh = @UB_KH;
--------------------------------------------------------------------------------
        update fh_waterused set LAST_QAN = (select  top 1 COUNT_QAN from #temp_waterate where userb_kh = @UB_KH 
      order By convert(datetime,CAST(HIS_YEAR AS VARCHAR)+'-'+CAST(HIS_MONTH AS VARCHAR)+'-1') desc) 
         where userb_kh = @UB_KH ;
--------------------------------------------------------------------------------
        update fh_waterused set LASTYEAR_QAN = (SELECT T2.COUNT_QAN FROM (SELECT * FROM FH_WATERUSED 
            WHERE USERB_KH = @UB_KH) T1,(SELECT * FROM #temp_waterate WHERE USERB_KH = @UB_KH) T2 
            WHERE CAST(T1.WATERU_YEAR-1 AS VARCHAR)+CAST(T1.WATERU_MONTH AS VARCHAR) =
        CAST(T2.HIS_YEAR AS VARCHAR)+CAST(T2.HIS_MONTH AS VARCHAR))  where userb_kh = @UB_KH;
--------------------------------------------------------------------------------
         update fh_waterused set CHANGE_QAN =(
          SELECT COALESCE(sum(T2.METERH_WATERQAN),0) FROM 
               (SELECT * FROM FH_WATERUSED WHERE USERB_KH = @UB_KH) T1,
      (SELECT * FROM FH_METERHIS WHERE USERB_KH = @UB_KH) T2 WHERE 
     CAST(T1.WATERU_YEAR AS VARCHAR)+CAST(T1.WATERU_MONTH AS VARCHAR) = 
     CAST(T2.BILL_YEAR AS VARCHAR)+CAST(T2.BILL_MONTH AS VARCHAR))  where userb_kh = @UB_KH;
--------------------------------------------------------------------------------
    --        update fh_waterused set count_qan = wateru_qan + change_qan where userb_kh = @UB_KH;
--------------------------------------------------------------------------------
         update fh_waterused set LASTTHREE_FLOAT = ROUND(CAST(COUNT_QAN-THREEMON_AVG AS FLOAT)/CAST(THREEMON_AVG AS FLOAT),2) where userb_kh = @UB_KH;
--------------------------------------------------------------------------------
            update fh_waterused set LAST_FLOAT = ROUND(CAST(COUNT_QAN-LAST_QAN AS FLOAT)/CAST(LAST_QAN AS FLOAT),2)  where userb_kh = @UB_KH;
--------------------------------------------------------------------------------
          update fh_waterused set LASTYEAR_FLOAT = ROUND(CAST(COUNT_QAN-LASTYEAR_QAN AS FLOAT)/CAST(LASTYEAR_QAN AS FLOAT),2) 
     where userb_kh = @UB_KH;

  --------------------------更新分析结果EXC_STATUS------------------------------------     
        SELECT @THREE1=ABS(LASTTHREE_FLOAT*100),
               @LASTY1=ABS(LASTYEAR_FLOAT*100),
               @LASTD1=ABS(LAST_FLOAT*100)
                   FROM FH_WATERUSED WHERE USERB_KH = @UB_KH;

        SELECT @THREE2=ABS(FRITREE_PARAM),
               @LASTY2=ABS(LASTYEAR_PARAM),
               @LASTD2=ABS(ON_PARAM)
                   FROM FH_ALARMPARAS;

        IF (@THREE1 < @THREE2 AND @LASTY1 <  @LASTY2 AND @LASTD1 <  @LASTD2)
           BEGIN
            UPDATE FH_WATERUSED SET EXC_STATUS = '0' WHERE USERB_KH = @UB_KH;
           END
        ELSE 
            BEGIN
            UPDATE FH_WATERUSED SET EXC_STATUS = '1' WHERE USERB_KH = @UB_KH;
           END
       fetch next from CUR_KH into  @UB_KH
      end
close CUR_KH
deallocate CUR_KH 
-----------------------------更新分析状态成已分析---------------------------------------------------
update FH_VOLUMESTATUS set VOLS_FXS = '1' WHERE VOLUME_NO = @VO_NO AND VOLS_YEAR = @PARA_YEAR AND VOLS_MONTH = @PARA_MONTH;

 --  SELECT @UB_KH,ROUND(CAST(COUNT_QAN-THREEMON_AVG AS FLOAT)/CAST(THREEMON_AVG AS FLOAT),2) F2,ROUND(CAST(COUNT_QAN-LAST_QAN AS FLOAT)/CAST(LAST_QAN AS FLOAT),2) F1,ROUND(CAST(COUNT_QAN-LASTYEAR_QAN AS FLOAT)/CAST(LASTYEAR_QAN AS FLOAT),2) F3 FROM FH_WATERUSED WHERE USERB_KH  = @UB_KH;

 
end
/*
-------------------------------------------
update fh_waterused set THREEMON_AVG = (select avg(t.wateru_qan) from (select top 3 wateru_qan from FH_WATERUSEDHIS where userb_kh = @UB_KH order by convert(datetime,CAST(HIS_YEAR AS VARCHAR)+'-'+CAST(HIS_MONTH AS VARCHAR)+'-1') desc)t) where userb_kh = @UB_KH;
update fh_waterused set LAST_QAN = (select  top 1 wateru_qan from FH_WATERUSEDHIS where userb_kh = @UB_KH order by convert(datetime,CAST(HIS_YEAR AS VARCHAR)+'-'+CAST(HIS_MONTH AS VARCHAR)+'-1') desc) where userb_kh = @UB_KH ;
update fh_waterused set LASTYEAR_QAN = (
SELECT T2.WATERU_QAN FROM 
(SELECT * FROM FH_WATERUSED WHERE USERB_KH = @UB_KH) T1,
(SELECT * FROM FH_WATERUSEDHIS WHERE USERB_KH = @UB_KH) T2 WHERE  CAST(T1.WATERU_YEAR-1 AS VARCHAR)+CAST(T1.WATERU_MONTH AS VARCHAR) =CAST(T2.HIS_YEAR AS VARCHAR)+CAST(T2.HIS_MONTH AS VARCHAR))  where userb_kh = @UB_KH;

update fh_waterused set CHANGE_QAN =(
SELECT COALESCE(sum(T2.METERH_WATERQAN),0) FROM 
(SELECT * FROM FH_WATERUSED WHERE USERB_KH = @UB_KH) T1,
(SELECT * FROM FH_METERHIS WHERE USERB_KH = @UB_KH) T2 WHERE  CAST(T1.WATERU_YEAR AS VARCHAR)+CAST(T1.WATERU_MONTH AS VARCHAR) =CAST(T2.BILL_YEAR AS VARCHAR)+CAST(T2.BILL_MONTH AS VARCHAR))  where userb_kh = @UB_KH;


-- SELECT * FROM FH_WATERUSED WHERE USERB_KH = @UB_KH;

  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server' */
GO

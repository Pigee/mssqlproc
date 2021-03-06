USE [jjwater]
GO
/****** Object:  UserDefinedFunction [dbo].[FUNC_WATER_SL]    Script Date: 10/18/2016 15:28:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[FUNC_WATER_SL]
( 
@UB_KH VARCHAR(20),
@INT_Y INT,
@INT_M INT,
@PARA VARCHAR(20) ---1为上月抄表水量，2为前三期平均抄表水量 3为去年同期抄表水量
)
RETURNS INT-- nvarchar
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
DECLARE @RESULT INT;

IF @PARA = '1'
select @RESULT = COUNT_QAN from FH_WATERUSEDHIS where userb_kh = @UB_KH AND convert(datetime,CAST(HIS_YEAR AS VARCHAR)+'-'+CAST(HIS_MONTH AS VARCHAR)+'-1') = DATEADD(month, -1, convert(datetime,CAST(@INT_Y AS VARCHAR)+'-'+CAST(@INT_M AS VARCHAR)+'-1'))

IF @PARA = '2'
select @RESULT = avg(t.COUNT_QAN) from (select top 3 COUNT_QAN from FH_WATERUSEDHIS where userb_kh = @UB_KH AND convert(datetime,CAST(HIS_YEAR AS VARCHAR)+'-'+CAST(HIS_MONTH AS VARCHAR)+'-1') < convert(datetime,CAST(@INT_Y AS VARCHAR)+'-'+CAST(@INT_M AS VARCHAR)+'-1') order by 
       convert(datetime,CAST(HIS_YEAR AS VARCHAR)+'-'+CAST(HIS_MONTH AS VARCHAR)+'-1') desc)t
 
IF @PARA = '3'
select @RESULT = COUNT_QAN from FH_WATERUSEDHIS where userb_kh = @UB_KH AND convert(datetime,CAST(HIS_YEAR AS VARCHAR)+'-'+CAST(HIS_MONTH AS VARCHAR)+'-1') = DATEADD(year, -1, convert(datetime,CAST(@INT_Y AS VARCHAR)+'-'+CAST(@INT_M AS VARCHAR)+'-1'))


 RETURN @RESULT
END
GO

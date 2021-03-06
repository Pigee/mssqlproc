USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_DMA_STATIC]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_DMA_STATIC]
@YEAR_INT INT, ---日期格式‘2016-03’
@MONTH_INT INT
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'

DELETE FROM FH_DMA_LOCALTJ WHERE DMA_YEAR = @YEAR_INT AND DMA_MONTH = @MONTH_INT;

IF YEAR(GETDATE()) = @YEAR_INT AND MONTH(GETDATE()) = @MONTH_INT
 BEGIN
        INSERT INTO FH_DMA_LOCALTJ SELECT newid(),x.dma_id,@YEAR_INT,@MONTH_INT,y.count_qan,NULL,'1',GETDATE(),NULL,NULL from fh_dma x left join (
select m.dma_id,sum(n.count_qan) count_qan from (
select dma_id,userb_kh from fh_dma_local where match_type = '2' union ALL
SELECT t2.DMA_ID,T1.USERB_KH FROM (
SELECT USERB_KH,VOLUME_NO FROM FH_USERBASE) T1,(
select dma_id,volume_no from fh_dma_local where match_type = '1') T2 WHERE T1.VOLUME_NO = T2.VOLUME_NO) m,(
SELECT USERB_KH,COUNT_QAN FROM FH_WATERUSED WHERE WATERU_YEAR = @YEAR_INT AND WATERU_MONTH = @MONTH_INT 
UNION ALL SELECT  USERB_KH,DMA_WATERU COUNT_QAN FROM FH_DMA_USED WHERE DMA_YEAR = @YEAR_INT AND DMA_MONTH = @MONTH_INT )n where m.userb_kh = n.userb_kh  group by dma_id)y on x.dma_id = y.dma_id;
 END
 ELSE
   BEGIN
     INSERT INTO FH_DMA_LOCALTJ SELECT newid(),x.dma_id,@YEAR_INT,@MONTH_INT,y.count_qan,NULL,'1',GETDATE(),NULL,NULL from fh_dma x left join (
select m.dma_id,sum(n.count_qan) count_qan from (
select dma_id,userb_kh from fh_dma_local where match_type = '2' union ALL
SELECT t2.DMA_ID,T1.USERB_KH FROM (
SELECT USERB_KH,VOLUME_NO FROM FH_USERBASE) T1,(
select dma_id,volume_no from fh_dma_local where match_type = '1') T2 WHERE T1.VOLUME_NO = T2.VOLUME_NO) m,(
SELECT USERB_KH,COUNT_QAN FROM FH_WATERUSEDHIS WHERE WATERU_YEAR = @YEAR_INT AND WATERU_MONTH = @MONTH_INT 
UNION ALL SELECT  USERB_KH,DMA_WATERU COUNT_QAN FROM FH_DMA_USED WHERE DMA_YEAR = @YEAR_INT AND DMA_MONTH = @MONTH_INT )n where m.userb_kh = n.userb_kh  group by dma_id)y on x.dma_id = y.dma_id;

   END


END
GO

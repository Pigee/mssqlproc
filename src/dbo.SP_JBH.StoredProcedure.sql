USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_JBH]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_JBH]
@VO_NO VARCHAR(36)
AS
BEGIN 
--SELECT @VO_NO AS VO_NO;
------------更新旧脚步号-----------------
---UPDATE FH_USERBASE SET USERB_JJBH = USERB_JBH WHERE VOLUME_NO = @VO_NO;

---------更新脚步号-----------------------
IF  EXISTS (SELECT * FROM SYSOBJECTS WHERE NAME='#TEMP_USERBASE')
 DROP TABLE #TEMP_USERBASE;

CREATE TABLE #TEMP_USERBASE(ID varchar(36),ROWNO int,jbh varchar(36));

IF @VO_NO IS NULL 
  BEGIN
     DECLARE @VO_SER VARCHAR(20);
     DECLARE VO_CUR CURSOR FOR SELECT VOLUME_NO from fh_volume;
      
     OPEN VO_CUR;
     FETCH NEXT FROM VO_CUR INTO @VO_SER;
     While(@@Fetch_Status = 0)
        Begin
          truncate table #TEMP_USERBASE;
          INSERT INTO #TEMP_USERBASE SELECT USERBase_ID, ROW_NUMBER()OVER(Order by cast(USERB_JBH as int) asc ) AS RowNumber,USERB_JBH FROM FH_USERBASE WHERE Volume_no = @VO_SER  ;
         -- SELECT * FROM #TEMP_USERBASE;
          update #TEMP_USERBASE set JBH =  Rowno*100;
           UPDATE #TEMP_USERBASE SET JBH = '00' + JBH WHERE LEN(JBH) = 3;
           UPDATE #TEMP_USERBASE SET JBH = '0' + JBH WHERE LEN(JBH) = 4;
						UPDATE A SET A.USERB_JBH = B.JBH FROM  FH_USERBASE A,#TEMP_USERBASE B WHERE A.USERBASE_ID = B.ID;
           --------------更新户号-----------------
            UPDATE FH_USERBASE SET USERB_HH = cast(volume_no as varchar)+cast(userb_jbh as varchar) where VOLUME_NO = @VO_SER;

           FETCH NEXT FROM VO_CUR INTO @VO_SER;
        END

  END
ELSE 
  BEGIN
INSERT INTO #TEMP_USERBASE SELECT USERBase_ID, ROW_NUMBER()OVER(Order by cast(USERB_JBH as int) asc ) AS RowNumber,
USERB_JBH FROM FH_USERBASE WHERE Volume_no = @VO_NO  ;
-- SELECT * FROM #TEMP_USERBASE;
update #TEMP_USERBASE set JBH =  Rowno*100;
UPDATE #TEMP_USERBASE SET JBH = '00' + JBH WHERE LEN(JBH) = 3;
UPDATE #TEMP_USERBASE SET JBH = '0' + JBH WHERE LEN(JBH) = 4;
 UPDATE A SET A.USERB_JBH = B.JBH FROM  FH_USERBASE A,#TEMP_USERBASE B WHERE A.USERBASE_ID = B.ID;
--------------更新户号-----------------
UPDATE FH_USERBASE SET USERB_HH = cast(volume_no as varchar)+cast(userb_jbh as varchar) where VOLUME_NO = @VO_NO;
END
-- SELECT * FROM #TEMP_USERBASE;

end
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
GO

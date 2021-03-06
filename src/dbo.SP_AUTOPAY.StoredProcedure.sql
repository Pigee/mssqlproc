USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_AUTOPAY]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_AUTOPAY]
@operUser varchar(36)
AS
BEGIN
                /*Author JiuPing Lee */
    DECLARE @userbKh varchar(20);
    DECLARE @cxYe money;
    DECLARE @yearInt int;
    DECLARE @aTotal money;
    DECLARE @znjTotal money;
    DECLARE @dayCount int;
    DECLARE @rate float;
    DECLARE @monInt int;
    DECLARE CX_CUR CURSOR FOR SELECT USERB_KH,CX_YE FROM FH_CX WHERE CX_YE > 0 FOR READ ONLY ;

set @rate = (select pen_rate from FH_PENALTY);  --獲取滯納金比例

OPEN CX_CUR
Fetch next from CX_CUR INTO @userbKh,@cxYe;    
   While(@@Fetch_Status = 0)
                  Begin
                     Begin
                               -- Select @GoodsCode = Convert(Char(20),@GoodsCode)
                               -- Select @GoodsName = Convert(Char(20),@GoodsName)
                               -- PRINT @GoodsCode + ':' + @GoodsName
                     ------------------------------------------------------------------
                             declare DEB_CUR CURSOR FOR
                             select DEBTL_YEAR,DEBTL_MON ,DEBTL_ATOTAL FROM FH_DEBTLIST WHERE USERB_KH = @userbKh AND PAY_TAG != 2
                             UNION ALL  select DEBTL_YEAR,DEBTL_MON,DEBTL_ATOTAL FROM FH_DEBTOWNHIS WHERE USERB_KH = @userbKh AND PAY_TAG != 2 order by DEBTL_YEAR,DEBTL_MON ASC; 
                                    OPEN DEB_CUR
                                      Fetch next from DEB_CUR INTO @yearInt,@monInt,@aTotal;
                                        While(@@Fetch_Status = 0)
                                          Begin
                                               Begin
                                                   /*
                                                  SET @dayCount = (select (case when t.dayC <0 then 0 else t.dayC end) from (
                                                   SELECT DATEDIFF(day,dateadd(month,1,CAST(@yearInt AS VARCHAR)+'-'+CAST(@monInt AS VARCHAR)+'-'+CAST(PAY_DATE AS VARCHAR)),GETDATE()) dayC
                                                              FROM FH_PENALTY) t);*/
                                                  SET @dayCount = dbo.FUNC_CALC_YQTS(@yearInt,@monInt,null);
                                                  
                                                   SET @znjTotal = dbo.FUNC_CALC_ZNJ(@yearInt,@monInt,@aTotal,NULL);
                                                   set @aTotal = @aTotal + dbo.FUNC_CALC_ZNJ(@yearInt,@monInt,@aTotal,NULL); 
                                                   -- select @aTotal,@dayCount,@cxYe; 
                                                 ----------------------------------------------------                                          
                                                 if @cxYe >= @aTotal 
                                                         BEGIN
                                                            UPDATE FH_CX SET CX_YE = ROUND(@cxYe-@aTotal,2) WHERE USERB_KH = @userbKh;
                                                            INSERT INTO FH_CXOPHIS(CXOPHIS_ID,USERB_KH,OPER_DATE,OPER_WAY,OPER_MONEY,CXOP_MONEY,OPER_YEAR,OPER_MONTH,OPER_USERID,OPER_YSJE,OPER_ZLJZE,OPER_YQTS,OPER_DESC)
                                                                 SELECT NEWid(),@userbKh,getdate(),'3',ROUND(@aTotal,2),ROUND(@cxYe-@aTotal,2),@yearInt,@monInt,@operUser,ROUND(@aTotal,2),ROUND(@znjTotal,2),@dayCount,'批量扣费';
                                                         -- set @aTotal = @aTotal
                                                              ----------------------------------------
                                                             IF @yearInt = year(getdate()) 	and @monInt = month(getdate())
                                                                 BEGIN
                                                                   UPDATE FH_DEBTLIST SET PAY_TAG = '2',PAY_DATE = GETDATE(),PAY_WAY = '11',DEBTL_ATOTAL = @aTotal where
                                                                      USERB_KH = @userbKh AND DEBTL_YEAR = @yearInt and DEBTL_MON = @monInt;
                                                                 END
                                                              else  
                                                                  BEGIN
                                                                   UPDATE FH_DEBTOWNHIS SET PAY_TAG = '2',PAY_DATE = GETDATE(),PAY_WAY = '11',DEBTL_ATOTAL = ROUND(@aTotal,2),DEBTL_ZNJ = ROUND(@znjTotal,2) where
                                                                      USERB_KH = @userbKh AND DEBTL_YEAR = @yearInt and DEBTL_MON = @monInt;
                                                                   -- UPDATE FH_DEBTHIS SET PAY_TAG = '2',PAY_DATE = GETDATE(),PAY_WAY = '11',DEBTL_ATOTAL = @aTotal where
                                                                      -- USERB_KH = @userbKh AND DEBTL_YEAR = @yearInt and DEBTL_MON = @monInt;
                                                                  END
                                                               ------------------------------------------------
                                                         set @cxYe = @cxYe-@aTotal;
                                                         end 
                                                  else BREAK
                                                 -------------------------------------------------------
                                        End
                                        Fetch next From DEB_CUR Into @yearInt,@monInt,@aTotal;
                                      End
                                   Close DEB_CUR
                              Deallocate DEB_CUR

                       ------------------------------------------------------------------   
                      -- select @userbKh,@cxYe;      
                      End
                Fetch next From CX_CUR Into @userbKh,@cxYe;
            End
            Close CX_CUR
            Deallocate CX_CUR

  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
END
GO

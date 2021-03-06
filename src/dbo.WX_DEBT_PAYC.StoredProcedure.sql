USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[WX_DEBT_PAYC]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[WX_DEBT_PAYC]
@DL_NO VARCHAR(36),--交易号
@WX_NO VARCHAR(100), -- 微信号
@IM_MONEY MONEY --交易金额
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
DECLARE @DB_ID VARCHAR(36)
DECLARE @DL_MONEY MONEY
DECLARE @UB_YE MONEY
DECLARE @UB_KH VARCHAR(36)-- 卡号
DECLARE @UB_ZNJ MONEY
DECLARE @UB_YEAR INT
DECLARE @UB_MON INT
DECLARE @WP_QAN INT
DECLARE @UB_SFFS VARCHAR(36)
DECLARE @INIT_MONEY MONEY
DECLARE DEBT_CUR CURSOR FOR SELECT DETAIL_ID,DEAL_MONEY,N_ZNJ,DEAL_YEAR,DEAL_MONTH,WATERP_QAN,USERB_SFFS FROM FH_WXDEALDETAIL WHERE DEAL_NO = @DL_NO;

select  @UB_KH = cust_kh FROM FH_WEIXINDEAL where DEAL_NO= @DL_NO;

IF @UB_KH IS NULL
  BEGIN 
   Deallocate DEBT_CUR; 
  RETURN;
  END
/*如果表FH_CX中有记录，则更新，否则插入 */
----------------------------
if exists (select 1 from FH_CX WHERE USERB_KH = @UB_KH) 
begin
SELECT @UB_YE = CX_YE FROM FH_CX WHERE USERB_KH = @UB_KH;
end 
else 
begin 
SET @UB_YE = 0
end

-----------------------------

SET @INIT_MONEY = @IM_MONEY
SET @IM_MONEY = @UB_YE + @IM_MONEY;
OPEN DEBT_CUR;
FETCH NEXT FROM DEBT_CUR INTO @DB_ID,@DL_MONEY,@UB_ZNJ,@UB_YEAR,@UB_MON,@WP_QAN,@UB_SFFS;
While(@@Fetch_Status = 0)
    Begin
                 IF @UB_YE <> 0 AND @UB_YE <= @DL_MONEY
                       BEGIN 
                       -- SET @UB_YE = 0
                       UPDATE FH_DEBTLIST SET PAY_TAG = '2',PAY_WAY ='3',PAY_DATE = GETDATE(),DEBTL_ATOTAL = @DL_MONEY,DEBTL_ZNJ = @UB_ZNJ,USERB_YHDM = '22'  WHERE USERB_KH = @UB_KH AND DEBTL_YEAR = @UB_YEAR AND DEBTL_MON = @UB_MON;
                       UPDATE FH_DEBTOWNHIS SET PAY_TAG = '2',PAY_WAY = '3',PAY_DATE = GETDATE(),DEBTL_ATOTAL = @DL_MONEY,DEBTL_ZNJ = @UB_ZNJ,USERB_YHDM = '22'  WHERE USERB_KH = @UB_KH AND DEBTL_YEAR = @UB_YEAR AND DEBTL_MON = @UB_MON;
                       -------------------
                       INSERT INTO [FH_FGTLIST] ([FGTLIST_ID], [FGTFLOW_NO], [FGT_MKEY],[USERB_KH], [FGT_YEAR],  [FGT_STOTAL], [FGT_ATOTAL], [FGT_WYJ], [FGT_LLEFT], [FGT_BLEFT], [FGT_TAG], [FGT_CZTAG], [FGT_SFDATE], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE], [FGT_WAY], [FGT_MONTH], [USERB_YHDM], [BANK_NUMBER], [CZFLOW_NO], [PAY_DATE],[WATERP_QAN],[USERB_SFFS]) 
                          SELECT NEWID(),@DL_NO,@UB_KH+dbo.FUNC_GETYM(@UB_YEAR,@UB_MON),@UB_KH,@UB_YEAR,@DL_MONEY-@UB_ZNJ,@DL_MONEY-@UB_YE,@UB_ZNJ,@UB_YE,0.0,'1','0',GETDATE(),'1',GETDATE(),NULL,NULL,'3',@UB_MON,'22','9999',NULL,GETDATE(),@WP_QAN,@UB_SFFS
                        -------------------
                       INSERT INTO [FH_CXOPHIS] ([CXOPHIS_ID], [USERB_KH], [OPER_DATE], [OPER_WAY], [OPER_MONEY], [CXOP_MONEY], [OPER_USERID], [OPER_KPDATE], [OPER_KPTAG], [OPER_KPH], [OPER_DYDATE], [OPER_HZTAG], [OPER_SFY], [OPER_ZLJZE], [OPER_YSJE], [OPER_YEAR], [OPER_MONTH], [OPER_YQTS], [OPER_ZNJ], [OPER_DESC]) 
                          SELECT NEWID(),@UB_KH,GETDATE(),'3',@UB_YE,0,'1',NULL,NULL,NULL,NULL,NULL,'1',@UB_ZNJ,@DL_MONEY,@UB_YEAR,@UB_MON,NULL,@UB_ZNJ,'微信支付'+dbo.FUNC_GETYM(@UB_YEAR,@UB_MON)
                        -------------------
                       UPDATE FH_CX SET CX_YE = 0 WHERE USERB_KH = @UB_KH;
                        -------------------
                       SET  @IM_MONEY = @IM_MONEY - @DL_MONEY
                       SET @UB_YE = 0
                       END
                     else IF @UB_YE > 0 AND @UB_YE > @DL_MONEY
                       BEGIN 
                       -- SET @UB_YE = 0
                       UPDATE FH_DEBTLIST SET PAY_TAG = '2',PAY_WAY ='3',PAY_DATE = GETDATE(),DEBTL_ATOTAL = @DL_MONEY,DEBTL_ZNJ = @UB_ZNJ,USERB_YHDM = '22' WHERE USERB_KH = @UB_KH AND DEBTL_YEAR = @UB_YEAR AND DEBTL_MON = @UB_MON;
                       UPDATE FH_DEBTOWNHIS SET PAY_TAG = '2',PAY_WAY = '3',PAY_DATE = GETDATE(),DEBTL_ATOTAL = @DL_MONEY,DEBTL_ZNJ = @UB_ZNJ,USERB_YHDM = '22'  WHERE USERB_KH = @UB_KH AND DEBTL_YEAR = @UB_YEAR AND DEBTL_MON = @UB_MON;
                       -------------------
                       INSERT INTO [FH_FGTLIST] ([FGTLIST_ID], [FGTFLOW_NO],  [FGT_MKEY],[USERB_KH],  [FGT_YEAR],  [FGT_STOTAL], [FGT_ATOTAL], [FGT_WYJ], [FGT_LLEFT], [FGT_BLEFT], [FGT_TAG], [FGT_CZTAG], [FGT_SFDATE], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE], [FGT_WAY], [FGT_MONTH], [USERB_YHDM], [BANK_NUMBER], [CZFLOW_NO], [PAY_DATE],[WATERP_QAN],[USERB_SFFS]) 
                          SELECT NEWID(),@DL_NO,@UB_KH+dbo.FUNC_GETYM(@UB_YEAR,@UB_MON),@UB_KH,@UB_YEAR,@DL_MONEY-@UB_ZNJ,0.0,@UB_ZNJ,@DL_MONEY,0.0,'1','0',GETDATE(),'1',GETDATE(),NULL,NULL,'3',@UB_MON,'22',NULL,NULL,GETDATE(),@WP_QAN,@UB_SFFS
                        -------------------
                       INSERT INTO [FH_CXOPHIS] ([CXOPHIS_ID], [USERB_KH], [OPER_DATE], [OPER_WAY], [OPER_MONEY], [CXOP_MONEY], [OPER_USERID], [OPER_KPDATE], [OPER_KPTAG], [OPER_KPH], [OPER_DYDATE], [OPER_HZTAG], [OPER_SFY], [OPER_ZLJZE], [OPER_YSJE], [OPER_YEAR], [OPER_MONTH], [OPER_YQTS], [OPER_ZNJ], [OPER_DESC]) 
                          SELECT NEWID(),@UB_KH,GETDATE(),'3',@DL_MONEY,@UB_YE-@DL_MONEY,'1',NULL,NULL,NULL,NULL,NULL,'1',@UB_ZNJ,@DL_MONEY,@UB_YEAR,@UB_MON,NULL,@UB_ZNJ,'微信支付'+dbo.FUNC_GETYM(@UB_YEAR,@UB_MON)
                        -------------------
                       UPDATE FH_CX SET CX_YE = @UB_YE-@DL_MONEY WHERE USERB_KH = @UB_KH;
                        -------------------
                       SET  @IM_MONEY = @IM_MONEY - @DL_MONEY
                       SET @UB_YE = @UB_YE-@DL_MONEY
                       END

                  ELSE 
                       BEGIN
                       UPDATE FH_DEBTLIST SET PAY_TAG = '2',PAY_WAY ='3',PAY_DATE = GETDATE(),DEBTL_ATOTAL = @DL_MONEY,DEBTL_ZNJ = @UB_ZNJ,USERB_YHDM = '22'  WHERE USERB_KH = @UB_KH AND DEBTL_YEAR = @UB_YEAR AND DEBTL_MON = @UB_MON;
                       UPDATE FH_DEBTOWNHIS SET PAY_TAG = '2',PAY_WAY = '3',PAY_DATE = GETDATE(),DEBTL_ATOTAL = @DL_MONEY,DEBTL_ZNJ = @UB_ZNJ,USERB_YHDM = '22'  WHERE USERB_KH = @UB_KH AND DEBTL_YEAR = @UB_YEAR AND DEBTL_MON = @UB_MON;
                       -------------------
                       INSERT INTO [FH_FGTLIST] ([FGTLIST_ID], [FGTFLOW_NO], [FGT_MKEY], [USERB_KH],  [FGT_YEAR],  [FGT_STOTAL], [FGT_ATOTAL], [FGT_WYJ], [FGT_LLEFT], [FGT_BLEFT], [FGT_TAG], [FGT_CZTAG], [FGT_SFDATE], [CREATE_PERSON], [CREATE_DATE], [UPDATE_PERSON], [UPDATE_DATE], [FGT_WAY], [FGT_MONTH], [USERB_YHDM], [BANK_NUMBER], [CZFLOW_NO], [PAY_DATE],[WATERP_QAN],[USERB_SFFS]) 
                          SELECT NEWID(),@DL_NO,@UB_KH+dbo.FUNC_GETYM(@UB_YEAR,@UB_MON),@UB_KH,@UB_YEAR,@DL_MONEY-@UB_ZNJ,@DL_MONEY,@UB_ZNJ,@UB_YE,0.0,'0','0',GETDATE(),'1',GETDATE(),NULL,NULL,'3',@UB_MON,'22',NULL,NULL,GETDATE(),@WP_QAN,@UB_SFFS
                        -------------------
                       --INSERT INTO [jjwater].[dbo].[FH_CXOPHIS] ([CXOPHIS_ID], [USERB_KH], [OPER_DATE], [OPER_WAY], [OPER_MONEY], [CXOP_MONEY], [OPER_USERID], [OPER_KPDATE], [OPER_KPTAG], [OPER_KPH], [OPER_DYDATE], [OPER_HZTAG], [OPER_SFY], [OPER_ZLJZE], [OPER_YSJE], [OPER_YEAR], [OPER_MONTH], [OPER_YQTS], [OPER_ZNJ], [OPER_DESC]) 
                       --   SELECT NEWID(),@UB_KH,GETDATE(),'3',@UB_YE,0,'1',NULL,NULL,NULL,NULL,NULL,'1',@UB_ZNJ,@DL_MONEY,@UB_YEAR,@UB_MON,NULL,@UB_ZNJ,'微信支付'+@DL_NO
                        -------------------
                       --UPDATE FH_CX SET CX_YE = 0 WHERE USERB_KH = @UB_KH;

                        SET  @IM_MONEY = @IM_MONEY - @DL_MONEY
                       END
          
                 --- SELECT @DB_ID,@DL_MONEY;
              FETCH NEXT FROM DEBT_CUR INTO @DB_ID,@DL_MONEY,@UB_ZNJ,@UB_YEAR,@UB_MON,@WP_QAN,@UB_SFFS;
   end;

 --------------如果 存在记录，更新最终余额,如果不存在记录，且最终余额大于0,则向FH_CX插入新记录-------             
if exists (select 1 from FH_CX WHERE USERB_KH = @UB_KH) 
 begin
    UPDATE FH_CX SET CX_YE = @IM_MONEY WHERE USERB_KH = @UB_KH;
     INSERT INTO [FH_CXOPHIS] ([CXOPHIS_ID], [USERB_KH], [OPER_DATE], [OPER_WAY], [OPER_MONEY], [CXOP_MONEY], [OPER_USERID], [OPER_KPDATE], [OPER_KPTAG], [OPER_KPH], [OPER_DYDATE], [OPER_HZTAG], [OPER_SFY], [OPER_ZLJZE], [OPER_YSJE], [OPER_YEAR], [OPER_MONTH], [OPER_YQTS], [OPER_ZNJ], [OPER_DESC]) 
                          SELECT NEWID(),@UB_KH,GETDATE(),'4',@IM_MONEY,@IM_MONEY,'1',NULL,NULL,NULL,NULL,NULL,'1',@UB_ZNJ,@DL_MONEY,@UB_YEAR,@UB_MON,NULL,@UB_ZNJ,'微信支付'+dbo.FUNC_GETYM(@UB_YEAR,@UB_MON)
 end 
else 
 begin 
   IF @IM_MONEY > 0
     begin
     INSERT INTO FH_CX VALUES (NEWID(),@UB_KH,@IM_MONEY,GETDATE(),'1');
     INSERT INTO [FH_CXOPHIS] ([CXOPHIS_ID], [USERB_KH], [OPER_DATE], [OPER_WAY], [OPER_MONEY], [CXOP_MONEY], [OPER_USERID], [OPER_KPDATE], [OPER_KPTAG], [OPER_KPH], [OPER_DYDATE], [OPER_HZTAG], [OPER_SFY], [OPER_ZLJZE], [OPER_YSJE], [OPER_YEAR], [OPER_MONTH], [OPER_YQTS], [OPER_ZNJ], [OPER_DESC]) 
                          SELECT NEWID(),@UB_KH,GETDATE(),'4',@IM_MONEY,@IM_MONEY,'1',NULL,NULL,NULL,NULL,NULL,'1',@UB_ZNJ,@DL_MONEY,@UB_YEAR,@UB_MON,NULL,@UB_ZNJ,'微信支付'+dbo.FUNC_GETYM(@UB_YEAR,@UB_MON)
      end     
 end     
--------------------------------------------------        
              UPDATE FH_FGTLIST SET FGT_BLEFT = @IM_MONEY,FGT_ATOTAL=FGT_ATOTAL+@IM_MONEY WHERE USERB_KH = @UB_KH AND FGT_YEAR=@UB_YEAR AND FGT_MONTH = @UB_MON;
            --   print @IM_MONEY;print @UB_YEAR;print @UB_KH;
              UPDATE FH_WEIXINDEAL SET DEAL_DATE = GETDATE(),STATUS = '1',SS_MONEY = @INIT_MONEY,WX_NO = @WX_NO WHERE CUST_KH = @UB_KH AND DEAL_NO = @DL_NO;
 Close DEBT_CUR
 Deallocate DEBT_CUR

END
GO

USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[BANK_CZ]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BANK_CZ]
@BANK_FLNO VARCHAR(36),  --冲正流水号
@UB_KH  VARCHAR(20),   --卡号
@DB_YEAR INT,  -- 账单时间年
@DB_MON INT --月
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
DECLARE @LLEFT MONEY;
DECLARE @BLEFT MONEY;
DECLARE @CXOP_M MONEY;

SELECT @LLEFT = FGT_LLEFT,@BLEFT = FGT_BLEFT FROM FH_FGTLIST where FGTFLOW_NO = @BANK_FLNO AND USERB_KH = @UB_KH AND FGT_YEAR = @DB_YEAR AND FGT_MONTH = @DB_MON;

UPDATE FH_DEBTLIST SET PAY_TAG = '0',DEBTL_ZNJ = 0.9,DEBTL_ATOTAL = DEBTL_STOTAL,PAY_DATE = NULL,BANK_PAYDATE = NULL WHERE USERB_KH = @UB_KH AND DEBTL_YEAR = @DB_YEAR AND DEBTL_MON = @DB_MON;

UPDATE FH_DEBTOWNHIS SET PAY_TAG = '0',DEBTL_ZNJ = 0.9,DEBTL_ATOTAL = DEBTL_STOTAL,PAY_DATE = NULL,BANK_PAYDATE = NULL WHERE USERB_KH = @UB_KH AND DEBTL_YEAR = @DB_YEAR AND DEBTL_MON = @DB_MON;


UPDATE FH_FGTLIST  set FGT_CZTAG = '1' where FGTFLOW_NO = @BANK_FLNO AND USERB_KH = @UB_KH AND FGT_YEAR = @DB_YEAR AND FGT_MONTH = @DB_MON;


--SELECT @CXOP_M = CX_YE+@LLEFT-@BLEFT FROM FH_CX;

IF @LLEFT <> 0 
BEGIN
SELECT @CXOP_M = CX_YE+@LLEFT FROM FH_CX;
INSERT FH_CXOPHIS(CXOPHIS_ID,USERB_KH,OPER_DATE,OPER_WAY,OPER_MONEY,CXOP_MONEY,OPER_DESC) SELECT  NEWID(),@UB_KH,GETDATE(),'??',@LLEFT,@CXOP_M,'冲正'+cast(@DB_YEAR as varchar) +'年'+ CASE WHEN @DB_MON < 10 THEN '0'+ cast(@DB_YEAR as varchar) ELSE cast(@DB_YEAR as varchar) END+'月水费';
 --      oper_way '',oper_money (bleft,lleft),cxop_money CX_YE(+LLEFT-BLEFT),OPER_DYDATE, OPER_DESC 冲正2013年10月水费
END

IF @BLEFT <> 0 
BEGIN
SELECT @CXOP_M = CX_YE+@LLEFT-@BLEFT FROM FH_CX;
INSERT FH_CXOPHIS(CXOPHIS_ID,USERB_KH,OPER_DATE,OPER_WAY,OPER_MONEY,CXOP_MONEY,OPER_DESC) SELECT  NEWID(),@UB_KH,GETDATE(),'??',@LLEFT,@CXOP_M,'冲正'+cast(@DB_YEAR as varchar) +'年'+ CASE WHEN @DB_MON < 10 THEN '0'+ cast(@DB_YEAR as varchar) ELSE cast(@DB_YEAR as varchar) END+'月水费';
 --      oper_way '',oper_money (bleft,lleft),cxop_money CX_YE(+LLEFT-BLEFT),OPER_DYDATE, OPER_DESC 冲正2013年10月水费
END

UPDATE FH_CX SET CX_YE = CX_YE+@LLEFT-@BLEFT WHERE USERB_KH = @UB_KH;



END
GO

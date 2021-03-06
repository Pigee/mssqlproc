USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[WX_DEBT_CREATE]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[WX_DEBT_CREATE]
@UB_KH VARCHAR(36),
@DL_NO VARCHAR(36)
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'

    INSERT INTO [FH_WXDEALDETAIL] ([DETAIL_ID], [DEAL_NO], [CUST_KH], [DEAL_YEAR], [DEAL_MONTH], [DEAL_MONEY], [N_ZNJ],[WATERP_QAN],[USERB_SFFS]) 
    SELECT T.DEBTLIST_ID,T.DL,T.UB,T.DEBTL_YEAR,T.DEBTL_MON,T.DEBTL_STOTAL,T.ZNJ,T.WATERP_QAN,T.USERB_SFFS FROM (   
          SELECT CAST(CAST(DEBTL_YEAR AS VARCHAR)+'-'+CAST(DEBTL_MON AS VARCHAR)+'-1' AS DATETIME) DT,DEBTLIST_ID,@DL_NO DL,@UB_KH UB,DEBTL_YEAR,DEBTL_MON,DEBTL_STOTAL,0 ZNJ,WATERP_QAN,IS_EXCPAY USERB_SFFS FROM FH_DEBTLIST WHERE USERB_KH = @UB_KH AND PAY_TAG = '0' AND (BANK_DEALTAG != '4'or BANK_DEALTAG is null)
             UNION ALL
             SELECT CAST(CAST(DEBTL_YEAR AS VARCHAR)+'-'+CAST(DEBTL_MON AS VARCHAR)+'-1' AS DATETIME) DT,DEBTLIST_ID,@DL_NO,@UB_KH,DEBTL_YEAR,DEBTL_MON,DBO.FUNC_CALC_ZNJ(DEBTL_YEAR, DEBTL_MON, DEBTL_STOTAL, NULL)+DEBTL_STOTAL,DBO.FUNC_CALC_ZNJ(DEBTL_YEAR, DEBTL_MON, DEBTL_STOTAL, NULL),WATERP_QAN,IS_EXCPAY  FROM FH_DEBTOWNHIS WHERE USERB_KH = @UB_KH AND PAY_TAG = '0'  AND (BANK_DEALTAG != '4'or BANK_DEALTAG is null))T
            ORDER BY T.DT;
    INSERT INTO FH_WEIXINDEAL(DEAL_ID,DEAL_NO,CUST_KH,DEAL_MONEY,CREATE_DATE,STATUS)
           SELECT NEWID(),@DL_NO,@UB_KH,SUM(DEAL_MONEY),GETDATE(),'0' FROM FH_WXDEALDETAIL WHERE DEAL_NO = @DL_NO;

END
GO

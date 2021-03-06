USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[WX_USERB_QFJE]    Script Date: 10/18/2016 15:28:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[WX_USERB_QFJE](@USERB_KH varchar(20))
as
BEGIN
 DECLARE  	@CXYE money
 	
					SELECT @CXYE=CX_YE FROM FH_CX CX WHERE CX.USERB_KH=@USERB_KH; 	
SELECT 		--T.DEBTLIST_ID,
										T.USERB_KH,
                   (SELECT USERB_HM FROM FH_USERBASE TU WHERE TU.USERB_KH=@USERB_KH)USERB_HM,
                    CASE WHEN  @CXYE IS NULL 
                     THEN '0'
                     ELSE 
                      @CXYE
                     END CX_YE,--余额
										SUM(T.DEBTL_ATOTAL)+SUM(T.DEBTL_ZNJ) QFJE,--欠费总金额
										(
											CASE WHEN
                      (SUM(T.DEBTL_ATOTAL)+SUM(T.DEBTL_ZNJ)- (CASE WHEN @CXYE IS NULL THEN 0 ELSE @CXYE END))<=0
											THEN 0 
											ELSE (SUM(T.DEBTL_ATOTAL)+SUM(T.DEBTL_ZNJ)- (CASE WHEN @CXYE IS NULL THEN 0 ELSE @CXYE END))
											END
										) C2,  --应缴纳金额,针对微信
                     SUM(T.DEBTL_ZNJ) ZNJ,--总滞纳金
                     sum(WATERP_QAN) QAN,  --总欠费水量
									   SUM(T.DEBTL_ATOTAL) JE,--欠费金额，不含滞纳金
										--(SELECT CASE WHEN (TT.DEBTL_ATOTAL+TT.DEBTL_ZNJ) IS NULL THEN 0 ELSE (TT.DEBTL_ATOTAL+TT.DEBTL_ZNJ) END FROM FH_DEBTLIST TT 
										--	WHERE TT.USERB_KH=@USERB_KH AND TT.PAY_TAG='0' AND (TT.BANK_DEALTAG!=4 or TT.BANK_DEALTAG is null)) CRT_MONTH_JE --当月欠费
										CASE WHEN 
											(SELECT (TT.DEBTL_ATOTAL+TT.DEBTL_ZNJ) FROM FH_DEBTLIST TT 
											WHERE TT.USERB_KH=@USERB_KH AND TT.PAY_TAG='0' AND (TT.BANK_DEALTAG!=4 or TT.BANK_DEALTAG is null))
										IS NULL THEN '0'
										ELSE 
											(SELECT (TT.DEBTL_ATOTAL+TT.DEBTL_ZNJ) FROM FH_DEBTLIST TT 
											WHERE TT.USERB_KH=@USERB_KH AND TT.PAY_TAG='0' AND (TT.BANK_DEALTAG!=4 or TT.BANK_DEALTAG is null))
										END CRT_MONTH_JE --当月欠费
					FROM (
						SELECT 	DEBTLIST_ID,
										USERB_KH,
										VOLUME_NO,
										USERB_HM,
										DEBTL_YEAR,
										DEBTL_MON,
										RECORD_DATE,
										USERB_SQDS,
										USERB_BQDS,
										WATERU_QAN,
										WATERP_QAN,
										PAY_WAY,
										PAY_TAG,
										PAY_DATE,
										0 DEBTL_ZNJ,
										DEBTL_ATOTAL
						FROM		FH_DEBTLIST 
						WHERE 	USERB_KH = @USERB_KH AND PAY_TAG='0' AND (BANK_DEALTAG!=4 or BANK_DEALTAG is null)
						UNION ALL
						SELECT 	DEBTLIST_ID,
										USERB_KH,
										VOLUME_NO,
										USERB_HM,
										DEBTL_YEAR,
										DEBTL_MON,
										RECORD_DATE,
										USERB_SQDS,
										USERB_BQDS,
										WATERU_QAN,
										WATERP_QAN,
										PAY_WAY,
										PAY_TAG,
										PAY_DATE,
										DBO.FUNC_CALC_ZNJ(DEBTL_YEAR, DEBTL_MON, DEBTL_STOTAL, NULL) DEBTL_ZNJ,
										DEBTL_ATOTAL
						FROM 		FH_DEBTOWNHIS
						WHERE 	 USERB_KH = @USERB_KH AND PAY_TAG='0'  AND (BANK_DEALTAG!=4 or BANK_DEALTAG is null) ) T
						GROUP BY T.USERB_KH
END
					--ORDER BY T.DEBTL_YEAR DESC, T.DEBTL_MON DESC
GO

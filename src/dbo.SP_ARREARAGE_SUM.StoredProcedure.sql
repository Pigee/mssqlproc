USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_ARREARAGE_SUM]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 *  功能：根据卡号统计用户的欠费信息,可查询托收用户数据。
 *  说明：1、该统计包含调整信息
 *  			2、统计字段为：欠费月数、欠费水量、欠费总违约金、欠费金额、欠费合计金额
 */
CREATE PROCEDURE [dbo].[SP_ARREARAGE_SUM](@USERB_KH VARCHAR(36))
AS
BEGIN
	DECLARE @PAY_TAG_PAYED VARCHAR(1), --收费标识：已收费
					@PAY_TAG_KEEP VARCHAR(1), --收费标识：托收
					@ADJUST_WATER VARCHAR(1), --调整水量
					@ADJUST_ZNJ VARCHAR(1); --调整违约金

	SELECT @PAY_TAG_PAYED = '2', @ADJUST_WATER = '0', @ADJUST_ZNJ = '1', @PAY_TAG_KEEP = '1';

	SELECT 	QFYS,
					CONVERT(VARCHAR(100), CAST(QFSL AS DECIMAL(38))  ) QFSL,
					CONVERT(VARCHAR(100), CAST(WYJ AS DECIMAL(38, 2))  ) WYJ,
					CONVERT(VARCHAR(100), CAST(QFJE AS DECIMAL(38, 2))  ) QFJE,
					CONVERT(VARCHAR(100), CAST(HJ AS DECIMAL(38, 2))  ) HJ
	FROM (
-------------------------------------------------------------------------------------
				SELECT 	COUNT(1) QFYS,	--欠费月数
								SUM(B.WATERP_QAN)  QFSL, --欠费水量
								SUM(B.DEBTL_ZNJ - ISNULL(C.ALT_QAN, 0) )  WYJ, 	--欠费总违约金
								SUM(B.DEBTL_ATOTAL - ISNULL(C.ALT_QAN, 0) )  QFJE,--欠费金额
								SUM(B.DEBTL_ATOTAL  + B.DEBTL_ZNJ - ISNULL(C.ALT_QAN, 0) )  HJ	--欠费合计金额
				FROM 		(
	-----------------------------------------------------------------------------------
						SELECT 	DEBTLIST_ID, WATERP_QAN, 0 DEBTL_ZNJ, DEBTL_ATOTAL
						FROM 		FH_DEBTLIST
						WHERE		PAY_TAG != @PAY_TAG_PAYED AND DEBTL_ATOTAL > 0 AND USERB_KH = @USERB_KH
						UNION 	ALL
						SELECT 	DEBTLIST_ID, WATERP_QAN, 
										CASE 
											WHEN PAY_TAG = @PAY_TAG_KEEP THEN --托收不收取违约金
												0
											ELSE
												dbo.FUNC_CALC_ZNJ(DEBTL_YEAR, DEBTL_MON, DEBTL_ATOTAL, NULL) 
										END DEBTL_ZNJ,
										DEBTL_ATOTAL
						FROM		FH_DEBTOWNHIS A
						WHERE		PAY_TAG != @PAY_TAG_PAYED AND DEBTL_ATOTAL > 0 AND USERB_KH = @USERB_KH
	------------------------------------------------------------------------------------			
				) B
				LEFT JOIN 	FH_PAYALT C --调整违约金
							 ON		B.DEBTLIST_ID = C.DEBTL_ID AND C.ALT_TYPE = @ADJUST_ZNJ
			/*	LEFT JOIN		FH_PAYALT D --调整水量 - ISNULL(D.ALT_QAN, 0)
							 ON		B.DEBTLIST_ID = D.DEBTL_ID AND D.ALT_TYPE = @ADJUST_WATER */
---------------------------------------------------------------------------------------------
	) E
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
END
GO

USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_CHARGE_QUERY_BANK]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
  功能：根据用户卡号查找用户欠费金额
  说明：1、查找的欠费金额为用户的欠费年月明细金额，且最早的一笔已扣除预存余额。
        2、目前使用与银企中间件。
  author： junlong&QY.lin
 */
CREATE PROCEDURE [dbo].[SP_CHARGE_QUERY_BANK]
(
	@USERB_KH VARCHAR(36)
)
AS
BEGIN
	DECLARE 	@CX_YE DECIMAL(38, 2), --预存余额
						@PAY_TAG VARCHAR(100), --收费标志：收费
						@TS_PAY_TAG VARCHAR(100), --托收收费标志：未收费
						@TZWYJ_TYPE VARCHAR(100); --调整违约金类型

	SELECT 	@CX_YE = ISNULL(CX_YE, 0)
	FROM		FH_CX
	WHERE		USERB_KH = @USERB_KH;

	IF @CX_YE IS NULL
			SET @CX_YE = 0;

	SELECT @PAY_TAG = '2', @TS_PAY_TAG = '1', @TZWYJ_TYPE = '1';

  SELECT 	USERB_KH, 
					YEAR_MON, 
					CASE 
						WHEN ROW_NUM = 1 AND DEBTL_ZNJ - @CX_YE < 0	THEN 0
						WHEN ROW_NUM = 1 AND DEBTL_ZNJ - @CX_YE >= 0 THEN DEBTL_ZNJ - @CX_YE
						ELSE DEBTL_ZNJ
					END DEBTL_ZNJ,
					CASE 
						WHEN ROW_NUM = 1	THEN DEBTL_ATOTAL + DEBTL_ZNJ - @CX_YE
						ELSE DEBTL_ATOTAL
					END DEBTL_ATOTAL, BANK_DEALTAG
	FROM
	(
			SELECT 	ROW_NUMBER() OVER (ORDER BY YEAR_MON ASC) ROW_NUM,
							USERB_KH, YEAR_MON, 
							(DEBTL_ZNJ - ISNULL(D.ALT_QAN, 0)) DEBTL_ZNJ, 
							(DEBTL_ZNJ + DEBTL_ATOTAL - ISNULL(D.ALT_QAN, 0)) DEBTL_ATOTAL, BANK_DEALTAG
			FROM		
			(
					SELECT 	DEBTLIST_ID, USERB_KH, (DEBTL_YEAR * 100 + DEBTL_MON) YEAR_MON, 0 DEBTL_ZNJ, 
									DEBTL_ATOTAL, BANK_DEALTAG
					FROM 		FH_DEBTLIST 
					WHERE		PAY_TAG != @PAY_TAG AND USERB_KH = @USERB_KH
				UNION ALL
					SELECT	DEBTLIST_ID, USERB_KH, (DEBTL_YEAR * 100 + DEBTL_MON) YEAR_MON, 
									CASE 
										WHEN PAY_TAG = @TS_PAY_TAG THEN 0
										ELSE DBO.FUNC_CALC_ZNJ(DEBTL_YEAR, DEBTL_MON, DEBTL_ATOTAL, NULL) 
									END DEBTL_ZNJ, 
									DEBTL_ATOTAL, BANK_DEALTAG
					FROM		FH_DEBTOWNHIS
					WHERE		PAY_TAG != @PAY_TAG AND USERB_KH = @USERB_KH
			) C
			LEFT JOIN 	FH_PAYALT D
						 ON		D.DEBTL_ID = C.DEBTLIST_ID AND D.ALT_TYPE = @TZWYJ_TYPE
	) E; 
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
END
GO

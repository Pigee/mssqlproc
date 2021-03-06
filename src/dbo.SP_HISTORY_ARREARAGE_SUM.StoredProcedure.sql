USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_HISTORY_ARREARAGE_SUM]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 *  功能：根据户号，区域，片区，册号统计用户的欠费信息,可查询托收用户数据。
 *  说明：1、该统计包含调整信息
 *  			2、统计字段为：
 *					 户号、户名、电话、册号、地址、欠费月数、欠费水量、欠费总违约金、欠费金额、欠费合计金额
 */
CREATE PROCEDURE [dbo].[SP_HISTORY_ARREARAGE_SUM]
(
		@AREA VARCHAR(36), -- 区域
		@AREA_NO VARCHAR(36), -- 片区
		@VOLUME_NO VARCHAR(36), -- 册号
		@USERB_KH VARCHAR(36) -- 户号
)
AS
BEGIN

	DECLARE @PAY_TAG_PAYED VARCHAR(1), --收费标识：已收费
					@PAY_TAG_KEEP VARCHAR(1), --收费标识：托收
					@ADJUST_WATER VARCHAR(1), --调整水量
					@ADJUST_ZNJ VARCHAR(1), --调整违约金
					@IS_ENABLED VARCHAR(1), --调整违约金
					@STATEMENT NVARCHAR(MAX), --执行语句
					@WHERE_CONDITION NVARCHAR(MAX); --条件

	SELECT @PAY_TAG_PAYED = '2', @ADJUST_WATER = '0', @ADJUST_ZNJ = '1', @PAY_TAG_KEEP = '1', @IS_ENABLED = '1';

	SET @WHERE_CONDITION = 
	'
			WHERE		PAY_TAG != ''' + @PAY_TAG_PAYED + ''' 
							AND DEBTL_ATOTAL > 0
	';

	IF @AREA IS NOT NULL
			SET @WHERE_CONDITION += 
			'
					AND CHANGE_RATETAG IN ( SELECT ORG_NO FROM FH_ORG WHERE ORG_SUPER_NO = ''' + @AREA + ''')
			';
	IF @AREA_NO IS NOT NULL
			SET @WHERE_CONDITION +=  
			'
					AND CHANGE_RATETAG =  ''' + @AREA_NO + '''
			';
	IF @VOLUME_NO IS NOT NULL
			SET @WHERE_CONDITION += 
			'
					AND VOLUME_NO =  ''' + @VOLUME_NO + '''
			';
	IF @USERB_KH IS NOT NULL
			SET @WHERE_CONDITION +=  
			'
					AND USERB_KH =  ''' + @USERB_KH + '''
			';

	SET @STATEMENT = 
	'
	SELECT 	F.USERB_KH, 
					F.USERB_HM,
					RTrim(ISNULL(F.USERB_DH,'''')) + ''/'' + ISNULL(F.USERB_MT, '''') USERB_DH,
 					F.VOLUME_NO,
 					F.USERB_ADDR,
					E.QFYS,
					CONVERT(VARCHAR(100), CAST(QFSL AS DECIMAL(38))  ) QFSL,
					CONVERT(VARCHAR(100), CAST(WYJ AS DECIMAL(38, 2))  ) WYJ,
					CONVERT(VARCHAR(100), CAST(QFJE AS DECIMAL(38, 2))  ) QFJE,
					CONVERT(VARCHAR(100), CAST(HJ AS DECIMAL(38, 2))  ) HJ
	FROM (
				SELECT 	B.USERB_KH,
								COUNT(1) QFYS,	--欠费月数
								SUM(B.WATERP_QAN)  QFSL, --欠费水量
								SUM(B.DEBTL_ZNJ - ISNULL(C.ALT_QAN, 0) )  WYJ, 	--欠费总违约金
								SUM(B.DEBTL_ATOTAL - ISNULL(C.ALT_QAN, 0) )  QFJE,--欠费金额
								SUM(B.DEBTL_ATOTAL  + B.DEBTL_ZNJ - ISNULL(C.ALT_QAN, 0) )  HJ	--欠费合计金额
				FROM 		(
						/*SELECT 	USERB_KH, DEBTLIST_ID, WATERP_QAN, 0 DEBTL_ZNJ, DEBTL_ATOTAL
						FROM 		FH_DEBTLIST
						' + @WHERE_CONDITION + '					
						UNION 	ALL */
						SELECT 	USERB_KH, DEBTLIST_ID, WATERP_QAN, 
										CASE 
											WHEN PAY_TAG = ''' + @PAY_TAG_KEEP + ''' THEN --托收不收取违约金
												0
											ELSE
												dbo.FUNC_CALC_ZNJ(DEBTL_YEAR, DEBTL_MON, DEBTL_ATOTAL, NULL) 
										END DEBTL_ZNJ,
										DEBTL_ATOTAL
						FROM		FH_DEBTOWNHIS A
						' + @WHERE_CONDITION + '
				) B
				LEFT JOIN 	FH_PAYALT C --调整违约金
							 ON		B.DEBTLIST_ID = C.DEBTL_ID AND C.ALT_TYPE = ''' + @ADJUST_ZNJ + '''

				GROUP BY B.USERB_KH

	) E
	INNER JOIN 	FH_USERBASE F
					ON 	F.IS_ENABLED = ''' + @IS_ENABLED + ''' AND F.USERB_KH = E.USERB_KH
	';
	PRINT @STATEMENT;
	EXEC SP_EXECUTESQL @STATEMENT,
		N'@AREA VARCHAR(36), @AREA_NO VARCHAR(36), @VOLUME_NO VARCHAR(36), @USERB_KH VARCHAR(36)',
		@AREA, @AREA_NO, @VOLUME_NO, @USERB_KH;

/*
	SELECT 	F.USERB_KH, 
					F.USERB_HM,
					ISNULL(F.USERB_DH,'''') + ''/'' + ISNULL(F.USERB_MT, '''') USERB_DH,
 					F.VOLUME_NO,
 					F.USER_ADDR,
					E.QFYS,
					CONVERT(VARCHAR(100), CAST(QFSL AS DECIMAL(38))  ) QFSL,
					CONVERT(VARCHAR(100), CAST(WYJ AS DECIMAL(38, 2))  ) WYJ,
					CONVERT(VARCHAR(100), CAST(QFJE AS DECIMAL(38, 2))  ) QFJE,
					CONVERT(VARCHAR(100), CAST(HJ AS DECIMAL(38, 2))  ) HJ
	FROM (
-------------------------------------------------------------------------------------
				SELECT 	USERB_KH,
								COUNT(1) QFYS,	--欠费月数
								SUM(B.WATERP_QAN)  QFSL, --欠费水量
								SUM(B.DEBTL_ZNJ - ISNULL(C.ALT_QAN, 0) )  WYJ, 	--欠费总违约金
								SUM(B.DEBTL_ATOTAL - ISNULL(C.ALT_QAN, 0) )  QFJE,--欠费金额
								SUM(B.DEBTL_ATOTAL  + B.DEBTL_ZNJ - ISNULL(C.ALT_QAN, 0) )  HJ	--欠费合计金额
				FROM 		(
	-----------------------------------------------------------------------------------
						SELECT 	USERB_KH, DEBTLIST_ID, WATERP_QAN, 0 DEBTL_ZNJ, DEBTL_ATOTAL
						FROM 		FH_DEBTLIST
						
						UNION 	ALL
						SELECT 	USERB_KH, DEBTLIST_ID, WATERP_QAN, 
										CASE 
											WHEN PAY_TAG = @PAY_TAG_KEEP THEN --托收不收取违约金
												0
											ELSE
												dbo.FUNC_CALC_ZNJ(DEBTL_YEAR, DEBTL_MON, DEBTL_ATOTAL, NULL) 
										END DEBTL_ZNJ,
										DEBTL_ATOTAL
						FROM		FH_DEBTOWNHIS A
						
	------------------------------------------------------------------------------------			
				) B
				LEFT JOIN 	FH_PAYALT C --调整违约金
							 ON		B.DEBTLIST_ID = C.DEBTL_ID AND C.ALT_TYPE = @ADJUST_ZNJ
			--	LEFT JOIN		FH_PAYALT D --调整水量 - ISNULL(D.ALT_QAN, 0)
			--				 ON		B.DEBTLIST_ID = D.DEBTL_ID AND D.ALT_TYPE = @ADJUST_WATER 
				GROUP BY USERB_KH
---------------------------------------------------------------------------------------------
	) E
	INNER JOIN 	FH_USERBASE F
					ON 	F.IS_ENABLED = @IS_ENABLED AND F.USERB_KH = E.USERB_KH
*/
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
END
GO

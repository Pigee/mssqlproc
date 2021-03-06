USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_CHARGE_QUERY_BEFORE]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_CHARGE_QUERY_BEFORE]
/**
 *	功能：分页查询账单明细
 *	说明：1、查询结果包含账单信息、调整信息、费用明细、阶梯信息
					2、可用于查找托收欠费记录
					3、对于有转义的，在原字段名后面加上_FORMAT
 */
(
		@USERB_KH VARCHAR(1000), --卡号
		@CURRENT_PAGE INT, --当前页
		@PAGE_SIZE INT --每页大小
)
AS
BEGIN
		DECLARE @STATEMENT NVARCHAR(MAX),
						@SF_TYPE VARCHAR(100), --水费类型
						@WSF_TYPE VARCHAR(100), --污水费类型
						@LJF_TYPE VARCHAR(100), --垃圾费类型
						@FJF_TYPE VARCHAR(100), --附加费类型
						@PAY_TAG VARCHAR(100), --收费标志：收费
						@TS_PAY_TAG VARCHAR(100), --托收收费标志：未收费
						@TZSL_TYPE VARCHAR(100), --调整水量类型
						@TZWYJ_TYPE VARCHAR(100), --调整违约金类型
						@BK_TYPE VARCHAR(100); --表况


		SELECT  @SF_TYPE = '01', @WSF_TYPE = '02', @LJF_TYPE = '03', @FJF_TYPE = '06',@PAY_TAG = '2',
						@TS_PAY_TAG = '1', @TZSL_TYPE = '0', @TZWYJ_TYPE = '1', @BK_TYPE = 'sbbk';

		IF @PAGE_SIZE IS NULL OR @PAGE_SIZE < 0
				SET @PAGE_SIZE = 10;
		IF @CURRENT_PAGE IS NULL OR @CURRENT_PAGE < 1
				SET @CURRENT_PAGE = 0;
		ELSE
				SET @CURRENT_PAGE = (@CURRENT_PAGE - 1) * @PAGE_SIZE;

		SET @STATEMENT = 
		'
		SELECT 	TOP ' + CAST(@PAGE_SIZE AS VARCHAR(20)) + ' *
		FROM 	(
				SELECT 	ROW_NUMBER() OVER (ORDER BY C.DEBTL_YEAR DESC, C.DEBTL_MON DESC) AS ROWNUMBER,
								C.DEBTLIST_ID,
								C.USERB_KH,
								C.DEBTL_YEAR,
								C.DEBTL_MON,
								C.USERB_SQDS,
								C.USERB_BQDS,
								C.WATERU_QAN,
								C.WATERC_QAN,
								C.WATERS_QAN,
								C.WATERQ_QAN,
								C.WATERB_QAN,
								C.WATERP_QAN,
								C.WATERM_STAT, C.WATERM_STAT_FORMAT,
								C.YSWYJ - C.JMWYJ DEBTL_ZNJ,
								C.DEBTL_ATOTAL + C.YSWYJ - C.JMWYJ DEBTL_ATOTAL,
								C.DEBTL_CPLUS,
								C.IS_PAY,
								C.DEBTL_STOTAL,
								C.CMETER_DATE, CONVERT(VARCHAR(100), C.CMETER_DATE, 20)  CMETER_DATE_FORMAT,
								C.RECORD_DATE, CONVERT(VARCHAR(100), C.RECORD_DATE, 20)  RECORD_DATE_FORMAT,
								C.PAY_TAG,
								C.PAY_DATE, CONVERT(VARCHAR(100), C.PAY_DATE, 20)  PAY_DATE_FORMAT,
								C.PAY_WAY,
								C.CHANGE_RATE,
								C.CHANGE_RATETAG,
								C.MONTH_TSPAY,
								C.RECORD_USER,
								C.LAST_TSVIOTOTAL,
								C.IS_EXCPAY,
								C.USERB_YHDM,
								C.BANK_NUMBER,
								C.BANK_TABNO,
								C.BANK_PAYDATE, CONVERT(VARCHAR(100), C.BANK_PAYDATE, 20)  BANK_PAYDATE_FORMAT,
								C.BANK_PAYQAN,
								C.BANK_DEALTAG,
								C.BANK_REMARK,
								C.WATERT_NO,
								C.WATER_PRICE,
								C.WATER_EXCPRICE,
								C.METER_CHTAG,
								C.MIXED_USEDTAG,
								C.EST_WATER,
								C.ROLLBACK_TAG,
								C.FREEPULL_TAG,
								C.CREATE_PERSON,
								C.CREATE_DATE, CONVERT(VARCHAR(100), C.CREATE_DATE, 20)  CREATE_DATE_FORMAT,
								C.UPDATE_PERSON,
								C.UPDATE_DATE, CONVERT(VARCHAR(100), C.UPDATE_DATE, 20)  UPDATE_DATE_FORMAT,
								C.DERATE_QAN,
								C.ADD_QAN,
								C.VOLUME_NO,
								C.USERB_HM,
								C.BANK_FLOWNO,
								C.IS_CBWAY,
								C.BC_TAG,
								C.YQTS,
								C.YSWYJ,
								C.JMWYJ,
								C.YSWYJ - C.JMWYJ SSWYJ,
								C.TZSL,
								C.DEBTL_ATOTAL + C.YSWYJ - C.JMWYJ HJ,

								F.PAYL_TOTAL SF,
								G.PAYL_TOTAL WSF,
								H.PAYL_TOTAL LJF,
								I.PAYL_TOTAL FJF,
								(	SELECT 	SUM(ISNULL(PAYL_TOTAL, 0)) PAYL_TOTAL 
									FROM 	FH_PAYLIST 
									WHERE 	C.DEBTLIST_ID = DEBTL_ID AND PAYL_NO NOT IN (''' + @SF_TYPE +''', ''' + @WSF_TYPE +''', ''' + @LJF_TYPE +''', ''' + @FJF_TYPE +''')
								) QTFY,

								K.STEP1_WATER,--第一档水量
								K.STEP1_FEE,--第一档水费
								K.STEP2_WATER,--第二档水量
								K.STEP2_FEE,--第二档水费
								K.STEP3_WATER,--第三档水量
								K.STEP3_FEE,--第三档水费
								K.TOTAL_WATER,--总水量
								K.TOTAL_FEE--总水费
				FROM 	(
					SELECT 	B.DEBTLIST_ID,
									B.USERB_KH,
									B.DEBTL_YEAR,
									B.DEBTL_MON,
									B.USERB_SQDS,
									B.USERB_BQDS,
									B.WATERU_QAN,
									B.WATERC_QAN,
									B.WATERS_QAN,
									B.WATERQ_QAN,
									B.WATERB_QAN,
									B.WATERP_QAN,
									B.WATERM_STAT, M.DATADIC_NAME WATERM_STAT_FORMAT,
									B.DEBTL_ZNJ,
									B.DEBTL_ATOTAL,
									B.DEBTL_CPLUS,
									B.IS_PAY,
									B.DEBTL_STOTAL,
									B.CMETER_DATE,
									B.RECORD_DATE,
									B.PAY_TAG,
									B.PAY_DATE,
									B.PAY_WAY,
									B.CHANGE_RATE,
									B.CHANGE_RATETAG,
									B.MONTH_TSPAY,
									B.RECORD_USER,
									B.LAST_TSVIOTOTAL,
									B.IS_EXCPAY,
									B.USERB_YHDM,
									B.BANK_NUMBER,
									B.BANK_TABNO,
									B.BANK_PAYDATE,
									B.BANK_PAYQAN,
									B.BANK_DEALTAG,
									B.BANK_REMARK,
									B.WATERT_NO,
									B.WATER_PRICE,
									B.WATER_EXCPRICE,
									B.METER_CHTAG,
									B.MIXED_USEDTAG,
									B.EST_WATER,
									B.ROLLBACK_TAG,
									B.FREEPULL_TAG,
									B.CREATE_PERSON,
									B.CREATE_DATE,
									B.UPDATE_PERSON,
									B.UPDATE_DATE,
									B.DERATE_QAN,
									B.ADD_QAN,
									B.VOLUME_NO,
									B.USERB_HM,
									B.BANK_FLOWNO,
									B.IS_CBWAY,
									B.BC_TAG,
									CASE 
											WHEN B.PAY_TAG = ''' + @TS_PAY_TAG + ''' THEN 0
											ELSE dbo.FUNC_CALC_YQTS(B.DEBTL_YEAR, B.DEBTL_MON, NULL) 
									END YQTS,
									CASE 
											WHEN B.PAY_TAG = ''' + @TS_PAY_TAG + ''' THEN 0
											ELSE dbo.FUNC_CALC_ZNJ(B.DEBTL_YEAR, B.DEBTL_MON, B.DEBTL_ATOTAL, NULL)
									END YSWYJ,
									ISNULL((	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
										FROM 		FH_PAYALT 
										WHERE 	DEBTL_ID = B.DEBTLIST_ID  AND ALT_TYPE = ''' + @TZWYJ_TYPE + '''
									), 0)  JMWYJ,
									0 SSWYJ,
									(	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
										FROM 		FH_PAYALT 
										WHERE 	DEBTL_ID = B.DEBTLIST_ID  AND ALT_TYPE = ''' + @TZSL_TYPE + '''
									)  TZSL
					FROM 		FH_DEBTOWNHIS B

					LEFT JOIN FH_DATADIC M
							ON 	B.WATERM_STAT = M.DATADIC_VALUE AND M.DATADIC_TYPE = ''' + @BK_TYPE + '''

					WHERE 	B.PAY_TAG != ''' + @PAY_TAG + ''' AND B.DEBTL_ATOTAL > 0 AND B.USERB_KH = @USERB_KH 
				) C

				LEFT JOIN FH_PAYLIST F --基本水费
							ON 	C.DEBTLIST_ID = F.DEBTL_ID AND F.PAYL_NO = ''' + @SF_TYPE +'''
				LEFT JOIN FH_PAYLIST G --污水处理费
							ON 	C.DEBTLIST_ID = G.DEBTL_ID AND G.PAYL_NO = ''' + @WSF_TYPE +'''
				LEFT JOIN FH_PAYLIST H --垃圾处理费
							ON 	C.DEBTLIST_ID = H.DEBTL_ID AND H.PAYL_NO = ''' + @LJF_TYPE +'''
				LEFT JOIN FH_PAYLIST I --附加费
							ON 	C.DEBTLIST_ID = I.DEBTL_ID AND I.PAYL_NO = ''' + @FJF_TYPE +'''
/*				LEFT JOIN FH_PAYLIST J --其他费用
							ON 	C.DEBTLIST_ID = J.DEBTL_ID AND J.PAYL_NO NOT IN (''' + @SF_TYPE +''', ''' + @WSF_TYPE +''', ''' + @LJF_TYPE +''', ''' + @FJF_TYPE +''')
*/
				LEFT JOIN FH_JTSS K --阶梯水费
							ON 	C.USERB_KH = K.USERB_KH AND C.DEBTL_YEAR = K.DEBTL_YEAR AND C.DEBTL_MON = K.DEBTL_MON
				

		) T
		WHERE ROWNUMBER > ' + CAST(@CURRENT_PAGE AS VARCHAR(20)) + '
		ORDER BY T.DEBTL_YEAR DESC, T.DEBTL_MON DESC
		';
/*
				LEFT JOIN FH_PAYALT D --调整违约金
							ON	C.DEBTLIST_ID = D.DEBTL_ID AND D.ALT_TYPE = ''' + @TZWYJ_TYPE +'''
				LEFT JOIN	FH_PAYALT E --调整水量
							ON	C.DEBTLIST_ID = E.DEBTL_ID AND E.ALT_TYPE = ''' + @TZSL_TYPE +'''
*/
--PRINT @STATEMENT;
		EXEC SP_EXECUTESQL @STATEMENT,
		N'@USERB_KH VARCHAR(36)',
		@USERB_KH;
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
END
GO

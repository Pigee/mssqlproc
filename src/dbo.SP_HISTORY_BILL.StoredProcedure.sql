USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_HISTORY_BILL]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
 *	功能：根据卡号、年份查找用户账单
 *	说明：1、查询结果包含账单信息、调整信息、费用明细、阶梯信息
					2、可用于查找托收欠费记录
					3、对于有转义的，在原字段名后面加上_FORMAT
		注意事项：当表fh_debtlist或fh_debthisXXXX有字段变动时，需要修改此过程
 */
CREATE PROCEDURE [dbo].[SP_HISTORY_BILL]
(
		@USERB_KH VARCHAR(36), --卡号
		@BILL_YEAR VARCHAR(4), --年份
		@IS_CONTAIN_ARREARS INT --是否包含欠费，0：不包含，其他包含
)
AS
BEGIN
		DECLARE @STATEMENT NVARCHAR(MAX),
						@SF_TYPE VARCHAR(100), --水费类型
						@WSF_TYPE VARCHAR(100), --污水费类型
						@LJF_TYPE VARCHAR(100), --垃圾费类型
						@FJF_TYPE VARCHAR(100), --附加费类型
						@PAY_TAG VARCHAR(100), --收费标志：收费
						@UNPAY_TAG VARCHAR(100), --收费标志：未收费
						@TS_PAY_TAG VARCHAR(100), --托收收费标志：未收费
						@TZSL_TYPE VARCHAR(100), --调整水量类型
						@TZWYJ_TYPE VARCHAR(100), --调整违约金类型
						@BK_TYPE VARCHAR(100), --表况
						@DEBTHIS_YEAR VARCHAR(MAX), --账单历史表
						@XZFS_TYPE VARCHAR(100); --销帐方式

		SELECT  @SF_TYPE = '01', @WSF_TYPE = '02', @LJF_TYPE = '03', @FJF_TYPE = '06',
						@PAY_TAG = '2',	@TS_PAY_TAG = '1', @TZSL_TYPE = '0', @TZWYJ_TYPE = '1', 
						@BK_TYPE = 'sbbk', @XZFS_TYPE  = 'fh_xzfs', @UNPAY_TAG = '0';

		--默认查询本年
		IF @BILL_YEAR IS NULL
			SET @BILL_YEAR = YEAR(GETDATE());

		SET @DEBTHIS_YEAR = 'FH_DEBTHIS' + @BILL_YEAR;

---------------------------------------------------------------------------------------
		IF OBJECT_ID(@DEBTHIS_YEAR, N'U') IS NULL
			BEGIN
				IF @IS_CONTAIN_ARREARS > 0
					BEGIN
						SELECT 	C.DEBTLIST_ID,
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
										C.SSWYJ DEBTL_ZNJ,
										C.DEBTL_ATOTAL + C.SSWYJ DEBTL_ATOTAL,
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
										C.DEBTL_ATOTAL + C.SSWYJ HJ,

										F.PAYL_TOTAL SF,
										G.PAYL_TOTAL WSF,
										H.PAYL_TOTAL LJF,
										I.PAYL_TOTAL FJF,
										(	SELECT 	SUM(ISNULL(PAYL_TOTAL, 0)) PAYL_TOTAL 
											FROM 	FH_PAYLIST 
											WHERE 	C.DEBTLIST_ID = DEBTL_ID AND PAYL_NO NOT IN (@SF_TYPE, @WSF_TYPE, @LJF_TYPE, @FJF_TYPE)
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
								SELECT 	A.DEBTLIST_ID,
												A.USERB_KH,
												A.DEBTL_YEAR,
												A.DEBTL_MON,
												A.USERB_SQDS,
												A.USERB_BQDS,
												A.WATERU_QAN,
												A.WATERC_QAN,
												A.WATERS_QAN,
												A.WATERQ_QAN,
												A.WATERB_QAN,
												A.WATERP_QAN,
												A.WATERM_STAT, L.DATADIC_NAME WATERM_STAT_FORMAT,
												A.DEBTL_ZNJ,
												A.DEBTL_ATOTAL,
												A.DEBTL_CPLUS,
												A.IS_PAY,
												A.DEBTL_STOTAL,
												A.CMETER_DATE,
												A.RECORD_DATE,
												A.PAY_TAG,
												A.PAY_DATE,
												A.PAY_WAY,
												A.CHANGE_RATE,
												A.CHANGE_RATETAG,
												A.MONTH_TSPAY,
												A.RECORD_USER,
												A.LAST_TSVIOTOTAL,
												A.IS_EXCPAY,
												A.USERB_YHDM,
												A.BANK_NUMBER,
												A.BANK_TABNO,
												A.BANK_PAYDATE,
												A.BANK_PAYQAN,
												A.BANK_DEALTAG,
												A.BANK_REMARK,
												A.WATERT_NO,
												A.WATER_PRICE,
												A.WATER_EXCPRICE,
												A.METER_CHTAG,
												A.MIXED_USEDTAG,
												A.EST_WATER,
												A.ROLLBACK_TAG,
												A.FREEPULL_TAG,
												A.CREATE_PERSON,
												A.CREATE_DATE,
												A.UPDATE_PERSON,
												A.UPDATE_DATE,
												A.DERATE_QAN,
												A.ADD_QAN,
												A.VOLUME_NO,
												A.USERB_HM,
												A.BANK_FLOWNO,
												A.IS_CBWAY,
												A.BC_TAG,
												0 YQTS,
												0 YSWYJ,
												ISNULL((	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
													FROM 		FH_PAYALT 
													WHERE 	DEBTL_ID = A.DEBTLIST_ID  AND ALT_TYPE = @TZWYJ_TYPE 
												), 0)  JMWYJ,
												0 SSWYJ,
												(	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
													FROM 		FH_PAYALT 
													WHERE 	DEBTL_ID = A.DEBTLIST_ID  AND ALT_TYPE = @TZSL_TYPE
												)  TZSL
								FROM		FH_DEBTLIST A

								LEFT JOIN FH_DATADIC L
										ON 	A.WATERM_STAT = L.DATADIC_VALUE AND L.DATADIC_TYPE = @BK_TYPE

								WHERE		A.PAY_TAG != @PAY_TAG AND A.DEBTL_ATOTAL > 0 
												AND A.DEBTL_YEAR = @BILL_YEAR AND A.USERB_KH = @USERB_KH

								UNION ALL
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
														WHEN B.PAY_TAG = @TS_PAY_TAG  THEN 0
														ELSE dbo.FUNC_CALC_YQTS(B.DEBTL_YEAR, B.DEBTL_MON, NULL) 
												END YQTS,
												CASE 
														WHEN B.PAY_TAG = @TS_PAY_TAG  THEN 0
														ELSE dbo.FUNC_CALC_ZNJ(B.DEBTL_YEAR, B.DEBTL_MON, B.DEBTL_ATOTAL, NULL)
												END YSWYJ,
												ISNULL((	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
													FROM 		FH_PAYALT 
													WHERE 	DEBTL_ID = B.DEBTLIST_ID  AND ALT_TYPE =  @TZWYJ_TYPE 
												), 0)  JMWYJ,
												0 SSWYJ,
												(	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
													FROM 		FH_PAYALT 
													WHERE 	DEBTL_ID = B.DEBTLIST_ID  AND ALT_TYPE =  @TZSL_TYPE 
												)  TZSL
								FROM 		FH_DEBTOWNHIS B

								LEFT JOIN FH_DATADIC M
										ON 	B.WATERM_STAT = M.DATADIC_VALUE AND M.DATADIC_TYPE = @BK_TYPE

								WHERE 	B.PAY_TAG != @PAY_TAG  AND B.DEBTL_ATOTAL > 0 
												AND B.DEBTL_YEAR = @BILL_YEAR AND B.USERB_KH = @USERB_KH 
							) C

							LEFT JOIN FH_PAYLIST F --基本水费
										ON 	C.DEBTLIST_ID = F.DEBTL_ID AND F.PAYL_NO = @SF_TYPE 
							LEFT JOIN FH_PAYLIST G --污水处理费
										ON 	C.DEBTLIST_ID = G.DEBTL_ID AND G.PAYL_NO = @WSF_TYPE 
							LEFT JOIN FH_PAYLIST H --垃圾处理费
										ON 	C.DEBTLIST_ID = H.DEBTL_ID AND H.PAYL_NO = @LJF_TYPE 
							LEFT JOIN FH_PAYLIST I --附加费
										ON 	C.DEBTLIST_ID = I.DEBTL_ID AND I.PAYL_NO = @FJF_TYPE 
		/*				LEFT JOIN FH_PAYLIST J --其他费用
									ON 	C.DEBTLIST_ID = J.DEBTL_ID AND J.PAYL_NO NOT IN (''' + @SF_TYPE +''', ''' + @WSF_TYPE +''', ''' + @LJF_TYPE +''', ''' + @FJF_TYPE +''')
		*/
							LEFT JOIN FH_JTSS K --阶梯水费
										ON 	C.USERB_KH = K.USERB_KH AND C.DEBTL_YEAR = K.DEBTL_YEAR AND C.DEBTL_MON = K.DEBTL_MON
						
							ORDER BY C.DEBTL_YEAR DESC, C.DEBTL_MON DESC
		
					END
			END
---------------------------------------------------------------------------------------
		ELSE
			BEGIN
				IF @IS_CONTAIN_ARREARS > 0
					BEGIN
						SET @STATEMENT =
						'
							SELECT 	DEBTLIST_ID,
											J.USERB_KH,
											J.DEBTL_YEAR,
											J.DEBTL_MON,
											USERB_SQDS,
											USERB_BQDS,
											WATERU_QAN,
											WATERC_QAN,
											WATERS_QAN,
											WATERQ_QAN,
											WATERB_QAN,
											WATERP_QAN,
											WATERM_STAT, WATERM_STAT_FORMAT,
											CASE 
													WHEN PAY_TAG = ''' + @UNPAY_TAG + ''' THEN YSWYJ - JMWYJ
													ELSE DEBTL_ZNJ
											END DEBTL_ZNJ,
											CASE 
													WHEN PAY_TAG = ''' + @UNPAY_TAG + ''' THEN DEBTL_ATOTAL + YSWYJ - JMWYJ
													ELSE DEBTL_ATOTAL
											END DEBTL_ATOTAL,
											DEBTL_CPLUS,
											IS_PAY,
											DEBTL_STOTAL,
											CMETER_DATE, CONVERT(VARCHAR(100), CMETER_DATE, 20) CMETER_DATE_FORMAT,
											RECORD_DATE, CONVERT(VARCHAR(100), RECORD_DATE, 20) RECORD_DATE_FORMAT,
											PAY_TAG,
											PAY_DATE, CONVERT(VARCHAR(100), PAY_DATE, 20)  PAY_DATE_FORMAT,
											PAY_WAY, J.PAY_WAY_FORMAT,
											CHANGE_RATE,
											CHANGE_RATETAG,
											MONTH_TSPAY,
											RECORD_USER,
											LAST_TSVIOTOTAL,
											IS_EXCPAY,
											USERB_YHDM,
											BANK_NUMBER,
											BANK_TABNO,
											BANK_PAYDATE, CONVERT(VARCHAR(100), BANK_PAYDATE, 20) BANK_PAYDATE_FORMAT,
											BANK_PAYQAN,
											BANK_DEALTAG,
											BANK_REMARK,
											WATERT_NO,
											WATER_PRICE,
											WATER_EXCPRICE,
											METER_CHTAG,
											MIXED_USEDTAG,
											EST_WATER,
											ROLLBACK_TAG,
											FREEPULL_TAG,
											J.CREATE_PERSON,
											J.CREATE_DATE, CONVERT(VARCHAR(100), J.CREATE_DATE, 20)  CREATE_DATE_FORMAT,
											J.UPDATE_PERSON,
											J.UPDATE_DATE, CONVERT(VARCHAR(100), J.UPDATE_DATE, 20)  UPDATE_DATE_FORMAT,
											DERATE_QAN,
											ADD_QAN,
											J.VOLUME_NO,
											J.USERB_HM,
											BANK_FLOWNO,
											IS_CBWAY,
											BC_TAG,
											YQTS,
											CASE 
													WHEN PAY_TAG = ''' + @UNPAY_TAG + ''' THEN YSWYJ
													ELSE DEBTL_ZNJ + JMWYJ
											END YSWYJ,
											JMWYJ,
											CASE 
													WHEN PAY_TAG = ''' + @UNPAY_TAG + ''' THEN YSWYJ - JMWYJ
													ELSE DEBTL_ZNJ
											END SSWYJ,
											TZSL,
											CASE 
													WHEN PAY_TAG = ''' + @UNPAY_TAG + ''' THEN DEBTL_ATOTAL + YSWYJ - JMWYJ
													ELSE DEBTL_ATOTAL
											END HJ,

											K.PAYL_TOTAL SF,
											L.PAYL_TOTAL WSF,
											M.PAYL_TOTAL LJF,
											N.PAYL_TOTAL FJF,
											(	SELECT 	SUM(ISNULL(PAYL_TOTAL, 0)) PAYL_TOTAL 
												FROM 	FH_PAYLIST 
												WHERE 	DEBTL_ID = J.DEBTLIST_ID AND PAYL_NO NOT IN (''' + @SF_TYPE +''', ''' + @WSF_TYPE +''', ''' + @LJF_TYPE +''', ''' + @FJF_TYPE +''')
											) QTFY,

											O.STEP1_WATER,
											O.STEP1_FEE,
											O.STEP2_WATER,
											O.STEP2_FEE,
											O.STEP3_WATER,
											O.STEP3_FEE,
											O.TOTAL_WATER,
											O.TOTAL_FEE
							FROM		(
									SELECT	A.*, 
													B.DATADIC_NAME WATERM_STAT_FORMAT,
													C.DATADIC_NAME PAY_WAY_FORMAT,
													0 YQTS,
													0 YSWYJ,
													ISNULL((	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
														FROM 		FH_PAYALT 
														WHERE 	DEBTL_ID = A.DEBTLIST_ID  AND ALT_TYPE = ''' + @TZWYJ_TYPE + '''
													),0)  JMWYJ,
													0 SSWYJ,
													(	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
														FROM 		FH_PAYALT 
														WHERE 	DEBTL_ID = A.DEBTLIST_ID  AND ALT_TYPE = ''' + @TZSL_TYPE + '''
													)  TZSL
									FROM 		FH_DEBTLIST A
									LEFT JOIN	FH_DATADIC B
											ON 	A.WATERM_STAT = B.DATADIC_VALUE AND B.DATADIC_TYPE = ''' + @BK_TYPE + '''
									LEFT JOIN FH_DATADIC C
											ON 	A.PAY_WAY = C.DATADIC_VALUE AND C.DATADIC_TYPE = ''' + @XZFS_TYPE + '''
									WHERE		A.DEBTL_YEAR = @BILL_YEAR AND A.USERB_KH = @USERB_KH
									UNION ALL
									SELECT	DEBTLIST_ID,
													D.USERB_KH,
													D.DEBTL_YEAR,
													D.DEBTL_MON,
													USERB_SQDS,
													USERB_BQDS,
													WATERU_QAN,
													WATERC_QAN,
													WATERS_QAN,
													WATERQ_QAN,
													WATERB_QAN,
													WATERP_QAN,
													WATERM_STAT,
													DEBTL_ZNJ,
													DEBTL_ATOTAL,
													DEBTL_CPLUS,
													IS_PAY,
													DEBTL_STOTAL,
													CMETER_DATE,
													RECORD_DATE,
													PAY_TAG,
													PAY_DATE,
													PAY_WAY,
													CHANGE_RATE,
													CHANGE_RATETAG,
													MONTH_TSPAY,
													RECORD_USER,
													LAST_TSVIOTOTAL,
													IS_EXCPAY,
													USERB_YHDM,
													BANK_NUMBER,
													BANK_TABNO,
													BANK_PAYDATE,
													BANK_PAYQAN,
													BANK_DEALTAG,
													BANK_REMARK,
													WATERT_NO,
													WATER_PRICE,
													WATER_EXCPRICE,
													METER_CHTAG,
													MIXED_USEDTAG,
													EST_WATER,
													ROLLBACK_TAG,
													FREEPULL_TAG,
													D.CREATE_PERSON,
													D.CREATE_DATE,
													D.UPDATE_PERSON,
													D.UPDATE_DATE,
													DERATE_QAN,
													ADD_QAN,
													D.VOLUME_NO,
													D.USERB_HM,
													BANK_FLOWNO,
													IS_CBWAY,
													BC_TAG,
													E.DATADIC_NAME WATERM_STAT_FORMAT,
													F.DATADIC_NAME PAY_WAY_FORMAT,
													CASE 
															WHEN D.PAY_TAG = ''' + @UNPAY_TAG + ''' THEN dbo.FUNC_CALC_YQTS(D.DEBTL_YEAR, D.DEBTL_MON, NULL)
															ELSE 0
													END YQTS,
													CASE 
															WHEN D.PAY_TAG = ''' + @UNPAY_TAG + '''  THEN dbo.FUNC_CALC_ZNJ(D.DEBTL_YEAR, D.DEBTL_MON, D.DEBTL_ATOTAL, NULL)
															ELSE D.DEBTL_ZNJ
													END YSWYJ,
													ISNULL((	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
														FROM 		FH_PAYALT 
														WHERE 	DEBTL_ID = D.DEBTLIST_ID  AND ALT_TYPE = ''' + @TZWYJ_TYPE + '''
													),0)  JMWYJ,
													0 SSWYJ,
													(	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
														FROM 		FH_PAYALT 
														WHERE 	DEBTL_ID = D.DEBTLIST_ID  AND ALT_TYPE = ''' + @TZSL_TYPE + '''
													)  TZSL
									FROM 		FH_DEBTOWNHIS D
									LEFT JOIN	FH_DATADIC E
											ON 	D.WATERM_STAT = E.DATADIC_VALUE AND E.DATADIC_TYPE = ''' + @BK_TYPE + '''
									LEFT JOIN FH_DATADIC F
											ON 	D.PAY_WAY = F.DATADIC_VALUE AND F.DATADIC_TYPE = ''' + @XZFS_TYPE + '''
									WHERE		D.DEBTL_YEAR = @BILL_YEAR AND D.USERB_KH = @USERB_KH
									UNION ALL
									SELECT	G.*,
													H.DATADIC_NAME WATERM_STAT_FORMAT,
													I.DATADIC_NAME PAY_WAY_FORMAT,
													0 YQTS,
													0 YSWYJ,
													ISNULL((	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
														FROM 		FH_PAYALT 
														WHERE 	DEBTL_ID = G.DEBTLIST_ID  AND ALT_TYPE = ''' + @TZWYJ_TYPE + '''
													), 0)  JMWYJ,
													G.DEBTL_ZNJ SSWYJ,
													(	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
														FROM 		FH_PAYALT 
														WHERE 	DEBTL_ID = G.DEBTLIST_ID  AND ALT_TYPE = ''' + @TZSL_TYPE + '''
													)  TZSL
									FROM 		' + @DEBTHIS_YEAR + ' G
									LEFT JOIN	FH_DATADIC H
											ON 	G.WATERM_STAT = H.DATADIC_VALUE AND H.DATADIC_TYPE = ''' + @BK_TYPE + '''
									LEFT JOIN FH_DATADIC I
											ON 	G.PAY_WAY = I.DATADIC_VALUE AND I.DATADIC_TYPE = ''' + @XZFS_TYPE + '''
									WHERE		G.DEBTL_YEAR = @BILL_YEAR AND G.USERB_KH = @USERB_KH

							) J
							LEFT JOIN FH_PAYLIST K 
										ON 	J.DEBTLIST_ID = K.DEBTL_ID AND K.PAYL_NO = ''' + @SF_TYPE +'''
							LEFT JOIN FH_PAYLIST L 
										ON 	J.DEBTLIST_ID = L.DEBTL_ID AND L.PAYL_NO = ''' + @WSF_TYPE +'''
							LEFT JOIN FH_PAYLIST M 
										ON 	J.DEBTLIST_ID = M.DEBTL_ID AND M.PAYL_NO = ''' + @LJF_TYPE +'''
							LEFT JOIN FH_PAYLIST N 
										ON 	J.DEBTLIST_ID = N.DEBTL_ID AND N.PAYL_NO = ''' + @FJF_TYPE +'''


							LEFT JOIN FH_JTSS O 
										ON 	J.USERB_KH = O.USERB_KH AND J.DEBTL_YEAR = O.DEBTL_YEAR AND J.DEBTL_MON = O.DEBTL_MON
							ORDER BY J.DEBTL_YEAR DESC, J.DEBTL_MON DESC
						';
					END
				ELSE
					BEGIN
						SET @STATEMENT =
						'
							SELECT 	DEBTLIST_ID,
											J.USERB_KH,
											J.DEBTL_YEAR,
											J.DEBTL_MON,
											USERB_SQDS,
											USERB_BQDS,
											WATERU_QAN,
											WATERC_QAN,
											WATERS_QAN,
											WATERQ_QAN,
											WATERB_QAN,
											WATERP_QAN,
											WATERM_STAT, WATERM_STAT_FORMAT,
											CASE 
													WHEN PAY_TAG = ''' + @UNPAY_TAG + ''' THEN YSWYJ - JMWYJ
													ELSE DEBTL_ZNJ
											END DEBTL_ZNJ,
											CASE 
													WHEN PAY_TAG = ''' + @UNPAY_TAG + ''' THEN DEBTL_ATOTAL + YSWYJ - JMWYJ
													ELSE DEBTL_ATOTAL
											END DEBTL_ATOTAL,
											DEBTL_CPLUS,
											IS_PAY,
											DEBTL_STOTAL,
											CMETER_DATE, CONVERT(VARCHAR(100), CMETER_DATE, 20)  CMETER_DATE_FORMAT,
											RECORD_DATE, CONVERT(VARCHAR(100), RECORD_DATE, 20)  RECORD_DATE_FORMAT,
											PAY_TAG,
											PAY_DATE, CONVERT(VARCHAR(100), PAY_DATE, 20)  PAY_DATE_FORMAT,
											PAY_WAY, PAY_WAY_FORMAT,
											CHANGE_RATE,
											CHANGE_RATETAG,
											MONTH_TSPAY,
											RECORD_USER,
											LAST_TSVIOTOTAL,
											IS_EXCPAY,
											USERB_YHDM,
											BANK_NUMBER,
											BANK_TABNO,
											BANK_PAYDATE, CONVERT(VARCHAR(100), BANK_PAYDATE, 20)  BANK_PAYDATE_FORMAT,
											BANK_PAYQAN,
											BANK_DEALTAG,
											BANK_REMARK,
											WATERT_NO,
											WATER_PRICE,
											WATER_EXCPRICE,
											METER_CHTAG,
											MIXED_USEDTAG,
											EST_WATER,
											ROLLBACK_TAG,
											FREEPULL_TAG,
											J.CREATE_PERSON,
											J.CREATE_DATE, CONVERT(VARCHAR(100), J.CREATE_DATE, 20)  CREATE_DATE_FORMAT,
											J.UPDATE_PERSON,
											J.UPDATE_DATE, CONVERT(VARCHAR(100), J.UPDATE_DATE, 20)  UPDATE_DATE_FORMAT,
											DERATE_QAN,
											ADD_QAN,
											J.VOLUME_NO,
											J.USERB_HM,
											BANK_FLOWNO,
											IS_CBWAY,
											BC_TAG,
											YQTS,
											CASE 
													WHEN PAY_TAG = ''' + @UNPAY_TAG + ''' THEN YSWYJ
													ELSE DEBTL_ZNJ + JMWYJ
											END YSWYJ,
											JMWYJ,
											CASE 
													WHEN PAY_TAG = ''' + @UNPAY_TAG + ''' THEN YSWYJ - JMWYJ
													ELSE DEBTL_ZNJ
											END SSWYJ,
											TZSL,
											CASE 
													WHEN PAY_TAG = ''' + @UNPAY_TAG + ''' THEN DEBTL_ATOTAL + YSWYJ - JMWYJ
													ELSE DEBTL_ATOTAL
											END HJ,

											K.PAYL_TOTAL SF,
											L.PAYL_TOTAL WSF,
											M.PAYL_TOTAL LJF,
											N.PAYL_TOTAL FJF,
											(	SELECT 	SUM(ISNULL(PAYL_TOTAL, 0)) PAYL_TOTAL 
												FROM 	FH_PAYLIST 
												WHERE 	DEBTL_ID = J.DEBTLIST_ID AND PAYL_NO NOT IN (''' + @SF_TYPE +''', ''' + @WSF_TYPE +''', ''' + @LJF_TYPE +''', ''' + @FJF_TYPE +''')
											) QTFY,

											O.STEP1_WATER,
											O.STEP1_FEE,
											O.STEP2_WATER,
											O.STEP2_FEE,
											O.STEP3_WATER,
											O.STEP3_FEE,
											O.TOTAL_WATER,
											O.TOTAL_FEE
							FROM		(
									SELECT	A.*, 
													B.DATADIC_NAME WATERM_STAT_FORMAT,
													C.DATADIC_NAME PAY_WAY_FORMAT,
													0 YQTS,
													0 YSWYJ,
													ISNULL((	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
														FROM 		FH_PAYALT 
														WHERE 	DEBTL_ID = A.DEBTLIST_ID  AND ALT_TYPE = ''' + @TZWYJ_TYPE + '''
													), 0)  JMWYJ,
													0 SSWYJ,
													(	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
														FROM 		FH_PAYALT 
														WHERE 	DEBTL_ID = A.DEBTLIST_ID  AND ALT_TYPE = ''' + @TZSL_TYPE + '''
													)  TZSL
									FROM 		FH_DEBTLIST A
									LEFT JOIN	FH_DATADIC B
											ON 	A.WATERM_STAT = B.DATADIC_VALUE AND B.DATADIC_TYPE = ''' + @BK_TYPE + '''
									LEFT JOIN FH_DATADIC C
											ON 	A.PAY_WAY = C.DATADIC_VALUE AND C.DATADIC_TYPE = ''' + @XZFS_TYPE + '''
									WHERE		A.PAY_TAG = ''' + @PAY_TAG + ''' AND A.DEBTL_YEAR = @BILL_YEAR AND A.USERB_KH = @USERB_KH
									UNION ALL
									SELECT	D.DEBTLIST_ID,
													D.USERB_KH,
													D.DEBTL_YEAR,
													D.DEBTL_MON,
													D.USERB_SQDS,
													D.USERB_BQDS,
													D.WATERU_QAN,
													D.WATERC_QAN,
													D.WATERS_QAN,
													D.WATERQ_QAN,
													D.WATERB_QAN,
													D.WATERP_QAN,
													D.WATERM_STAT,
													D.DEBTL_ZNJ,
													D.DEBTL_ATOTAL,
													D.DEBTL_CPLUS,
													D.IS_PAY,
													D.DEBTL_STOTAL,
													D.CMETER_DATE,
													D.RECORD_DATE,
													D.PAY_TAG,
													D.PAY_DATE,
													D.PAY_WAY,
													D.CHANGE_RATE,
													D.CHANGE_RATETAG,
													D.MONTH_TSPAY,
													D.RECORD_USER,
													D.LAST_TSVIOTOTAL,
													D.IS_EXCPAY,
													D.USERB_YHDM,
													D.BANK_NUMBER,
													D.BANK_TABNO,
													D.BANK_PAYDATE,
													D.BANK_PAYQAN,
													D.BANK_DEALTAG,
													D.BANK_REMARK,
													D.WATERT_NO,
													D.WATER_PRICE,
													D.WATER_EXCPRICE,
													D.METER_CHTAG,
													D.MIXED_USEDTAG,
													D.EST_WATER,
													D.ROLLBACK_TAG,
													D.FREEPULL_TAG,
													D.CREATE_PERSON,
													D.CREATE_DATE,
													D.UPDATE_PERSON,
													D.UPDATE_DATE,
													D.DERATE_QAN,
													D.ADD_QAN,
													D.VOLUME_NO,
													D.USERB_HM,
													D.BANK_FLOWNO,
													D.IS_CBWAY,
													D.BC_TAG,
													E.DATADIC_NAME WATERM_STAT_FORMAT,
													F.DATADIC_NAME PAY_WAY_FORMAT,
													CASE 
															WHEN D.PAY_TAG = ''' + @UNPAY_TAG + ''' THEN dbo.FUNC_CALC_YQTS(D.DEBTL_YEAR, D.DEBTL_MON, NULL)
															ELSE 0
													END YQTS,
													CASE 
															WHEN D.PAY_TAG = ''' + @UNPAY_TAG + '''  THEN dbo.FUNC_CALC_ZNJ(D.DEBTL_YEAR, D.DEBTL_MON, D.DEBTL_ATOTAL, NULL)
															ELSE D.DEBTL_ZNJ
													END YSWYJ,
													ISNULL((	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
														FROM 		FH_PAYALT 
														WHERE 	DEBTL_ID = D.DEBTLIST_ID  AND ALT_TYPE = ''' + @TZWYJ_TYPE + '''
													), 0)  JMWYJ,
													0 SSWYJ,
													(	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
														FROM 		FH_PAYALT 
														WHERE 	DEBTL_ID = D.DEBTLIST_ID  AND ALT_TYPE = ''' + @TZSL_TYPE + '''
													)  TZSL
									FROM 		FH_DEBTOWNHIS D
									LEFT JOIN	FH_DATADIC E
											ON 	D.WATERM_STAT = E.DATADIC_VALUE AND E.DATADIC_TYPE = ''' + @BK_TYPE + '''
									LEFT JOIN FH_DATADIC F
											ON 	D.PAY_WAY = F.DATADIC_VALUE AND F.DATADIC_TYPE = ''' + @XZFS_TYPE + '''
									WHERE		D.PAY_TAG = ''' + @PAY_TAG + ''' AND D.DEBTL_YEAR = @BILL_YEAR AND D.USERB_KH = @USERB_KH
									UNION ALL
									SELECT	G.*,
													H.DATADIC_NAME WATERM_STAT_FORMAT,
													I.DATADIC_NAME PAY_WAY_FORMAT,
													0 YQTS,
													0 YSWYJ,
													ISNULL((	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
														FROM 		FH_PAYALT 
														WHERE 	DEBTL_ID = G.DEBTLIST_ID  AND ALT_TYPE = ''' + @TZWYJ_TYPE + '''
													), 0)  JMWYJ,
													G.DEBTL_ZNJ SSWYJ,
													(	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
														FROM 		FH_PAYALT 
														WHERE 	DEBTL_ID = G.DEBTLIST_ID  AND ALT_TYPE = ''' + @TZSL_TYPE + '''
													)  TZSL
									FROM 		' + @DEBTHIS_YEAR + ' G
									LEFT JOIN	FH_DATADIC H
											ON 	G.WATERM_STAT = H.DATADIC_VALUE AND H.DATADIC_TYPE = ''' + @BK_TYPE + '''
									LEFT JOIN FH_DATADIC I
											ON 	G.PAY_WAY = I.DATADIC_VALUE AND I.DATADIC_TYPE = ''' + @XZFS_TYPE + '''
									WHERE		G.DEBTL_YEAR = @BILL_YEAR AND G.USERB_KH = @USERB_KH

							) J
							LEFT JOIN FH_PAYLIST K 
										ON 	J.DEBTLIST_ID = K.DEBTL_ID AND K.PAYL_NO = ''' + @SF_TYPE +'''
							LEFT JOIN FH_PAYLIST L 
										ON 	J.DEBTLIST_ID = L.DEBTL_ID AND L.PAYL_NO = ''' + @WSF_TYPE +'''
							LEFT JOIN FH_PAYLIST M 
										ON 	J.DEBTLIST_ID = M.DEBTL_ID AND M.PAYL_NO = ''' + @LJF_TYPE +'''
							LEFT JOIN FH_PAYLIST N 
										ON 	J.DEBTLIST_ID = N.DEBTL_ID AND N.PAYL_NO = ''' + @FJF_TYPE +'''


							LEFT JOIN FH_JTSS O 
										ON 	J.USERB_KH = O.USERB_KH AND J.DEBTL_YEAR = O.DEBTL_YEAR AND J.DEBTL_MON = O.DEBTL_MON
							ORDER BY J.DEBTL_YEAR DESC, J.DEBTL_MON DESC
						';
					END
				EXEC SP_EXECUTESQL @STATEMENT,
				N'@USERB_KH VARCHAR(36), @BILL_YEAR VARCHAR(4)',
				@USERB_KH, @BILL_YEAR;
			END
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
END
GO

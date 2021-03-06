USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[sp_temp_test]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_temp_test]
AS
BEGIN
  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
/*SELECT 	DEBTLIST_ID,
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
													WHEN PAY_TAG = '0' THEN YSWYJ - JMWYJ
													ELSE DEBTL_ZNJ
											END DEBTL_ZNJ,
											CASE 
													WHEN PAY_TAG = '0' THEN DEBTL_ATOTAL + YSWYJ - JMWYJ
													ELSE DEBTL_ATOTAL
											END DEBTL_ATOTAL,
											DEBTL_CPLUS,
											IS_PAY,
											DEBTL_STOTAL,
											CMETER_DATE,CONVERT(VARCHAR(100), CMETER_DATE, 20)  CMETER_DATE_FORMAT,
											RECORD_DATE,CONVERT(VARCHAR(100), RECORD_DATE, 20)  RECORD_DATE_FORMAT,
											PAY_TAG,
											PAY_DATE,CONVERT(VARCHAR(100), PAY_DATE, 20)  PAY_DATE_FORMAT,
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
											BANK_PAYDATE,CONVERT(VARCHAR(100), BANK_PAYDATE, 20)  BANK_PAYDATE_FORMAT,
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
											J.CREATE_DATE,CONVERT(VARCHAR(100), J.CREATE_DATE, 20)  CREATE_DATE_FORMAT,
											J.UPDATE_PERSON,
											J.UPDATE_DATE,CONVERT(VARCHAR(100), J.UPDATE_DATE, 20)  UPDATE_DATE_FORMAT,
											DERATE_QAN,
											ADD_QAN,
											VOLUME_NO,
											USERB_HM,
											BANK_FLOWNO,
											IS_CBWAY,
											BC_TAG,
											YQTS,
											CASE 
													WHEN PAY_TAG = '0' THEN YSWYJ
													ELSE DEBTL_ZNJ + JMWYJ
											END YSWYJ,
											JMWYJ,
											CASE 
													WHEN PAY_TAG = '0' THEN YSWYJ - JMWYJ
													ELSE DEBTL_ZNJ
											END SSWYJ,
											TZSL,

											K.PAYL_TOTAL SF,
											L.PAYL_TOTAL WSF,
											M.PAYL_TOTAL LJF,
											N.PAYL_TOTAL FJF,
											(	SELECT 	SUM(ISNULL(PAYL_TOTAL, 0)) PAYL_TOTAL 
												FROM 	FH_PAYLIST 
												WHERE 	DEBTL_ID = DEBTLIST_ID AND PAYL_NO NOT IN ('01', '02', '03', '06')
											) QTFY,

											O.STEP1_WATER,--第一档水量
											O.STEP1_FEE,--第一档水费
											O.STEP2_WATER,--第二档水量
											O.STEP2_FEE,--第二档水费
											O.STEP3_WATER,--第三档水量
											O.STEP3_FEE,--第三档水费
											O.TOTAL_WATER,--总水量
											O.TOTAL_FEE--总水费
							FROM		(
									SELECT	A.*, 
													B.DATADIC_NAME WATERM_STAT_FORMAT,
													C.DATADIC_NAME PAY_WAY_FORMAT,
													0 YQTS,
													0 YSWYJ,
													(	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
														FROM 		FH_PAYALT 
														WHERE 	DEBTL_ID = A.DEBTLIST_ID  AND ALT_TYPE = '1'
													)  JMWYJ,
													0 SSWYJ,
													(	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
														FROM 		FH_PAYALT 
														WHERE 	DEBTL_ID = A.DEBTLIST_ID  AND ALT_TYPE = '0'
													)  TZSL
									FROM 		FH_DEBTLIST A
									LEFT JOIN	FH_DATADIC B
											ON 	A.WATERM_STAT = B.DATADIC_VALUE AND B.DATADIC_TYPE = 'sbbk'
									LEFT JOIN FH_DATADIC C
											ON 	A.PAY_WAY = C.DATADIC_VALUE AND C.DATADIC_TYPE = 'fh_xzfs'
									WHERE		A.DEBTL_YEAR = '2000' AND A.USERB_KH = '004595'
									union all
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
															WHEN D.PAY_TAG = '0' THEN dbo.FUNC_CALC_YQTS(D.DEBTL_YEAR, D.DEBTL_MON, NULL)
															ELSE 0
													END YQTS,
													CASE 
															WHEN D.PAY_TAG = '0'  THEN dbo.FUNC_CALC_ZNJ(D.DEBTL_YEAR, D.DEBTL_MON, D.DEBTL_ATOTAL, NULL)
															ELSE D.DEBTL_ZNJ
													END YSWYJ,
													(	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
														FROM 		FH_PAYALT 
														WHERE 	DEBTL_ID = D.DEBTLIST_ID  AND ALT_TYPE = '1'
													)  JMWYJ,
													0 SSWYJ,
													(	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
														FROM 		FH_PAYALT 
														WHERE 	DEBTL_ID = D.DEBTLIST_ID  AND ALT_TYPE = '0'
													)  TZSL
									FROM 		FH_DEBTLIST D
									LEFT JOIN	FH_DATADIC E
											ON 	D.WATERM_STAT = E.DATADIC_VALUE AND E.DATADIC_TYPE = 'sbbk'
									LEFT JOIN FH_DATADIC F
											ON 	D.PAY_WAY = F.DATADIC_VALUE AND F.DATADIC_TYPE = 'fh_xzfs'
									WHERE		D.DEBTL_YEAR = '2000' AND D.USERB_KH = '004595'
									union all
									SELECT	G.*,
													H.DATADIC_NAME WATERM_STAT_FORMAT,
													I.DATADIC_NAME PAY_WAY_FORMAT,
													0 YQTS,
													0 YSWYJ,
													(	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
														FROM 		FH_PAYALT 
														WHERE 	DEBTL_ID = G.DEBTLIST_ID  AND ALT_TYPE = '1'
													)  JMWYJ,
													G.DEBTL_ZNJ SSWYJ,
													(	SELECT 	SUM(ISNULL(ALT_QAN, 0)) ALT_QAN 
														FROM 		FH_PAYALT 
														WHERE 	DEBTL_ID = G.DEBTLIST_ID  AND ALT_TYPE = '0'
													)  TZSL
									FROM 		FH_DEBTLIST G
									LEFT JOIN	FH_DATADIC H
											ON 	G.WATERM_STAT = H.DATADIC_VALUE AND H.DATADIC_TYPE = 'sbbk'
									LEFT JOIN FH_DATADIC I
											ON 	G.PAY_WAY = I.DATADIC_VALUE AND I.DATADIC_TYPE = 'fh_xzfs'
									WHERE		G.DEBTL_YEAR = '2000' AND G.USERB_KH = '004595'

							) J
							LEFT JOIN FH_PAYLIST K --基本水费
										ON 	DEBTLIST_ID = K.DEBTL_ID AND K.PAYL_NO = '01'
							LEFT JOIN FH_PAYLIST L --污水处理费
										ON 	DEBTLIST_ID = L.DEBTL_ID AND L.PAYL_NO = '02'
							LEFT JOIN FH_PAYLIST M --垃圾处理费
										ON 	DEBTLIST_ID = M.DEBTL_ID AND M.PAYL_NO = '03'
							LEFT JOIN FH_PAYLIST N --附加费
										ON 	DEBTLIST_ID = N.DEBTL_ID AND N.PAYL_NO = '06'


							LEFT JOIN FH_JTSS O --阶梯水费
										ON 	J.USERB_KH = O.USERB_KH AND J.DEBTL_YEAR = O.DEBTL_YEAR AND J.DEBTL_MON = O.DEBTL_MON
							ORDER BY J.DEBTL_YEAR DESC, J.DEBTL_MON DESC;*/

	 RAISERROR ('Parameter ''role_type_id'' can not be null.' , 16, 1) WITH NOWAIT
END
GO

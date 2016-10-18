USE [jjwater]
GO
/****** Object:  StoredProcedure [dbo].[SP_FIND_DEBT]    Script Date: 10/18/2016 15:28:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**
  功能：根据用户卡号、账单年月查找用户账单
  说明：用户卡号、账单年月可以确定唯一的一条账单记录。
*/
CREATE PROCEDURE [dbo].[SP_FIND_DEBT](@USERB_KH VARCHAR(36), @DEBTL_YEAR INT, @DEBTL_MON INT)
AS
BEGIN
	DECLARE @TABLE_NAME VARCHAR(100),
					@STATEMENT NVARCHAR(MAX),
					@DATADIC_TYPE VARCHAR(100);
	SET @DATADIC_TYPE = 'fh_xzfs';--销帐方式
	--当前年月直接查询，因为不用计算滞纳金
	IF @DEBTL_YEAR = YEAR(GETDATE()) AND @DEBTL_MON = MONTH(GETDATE())
		BEGIN
			SELECT 	DEBTLIST_ID, WATERT_NO, WATERP_QAN, PAY_WAY, B.DATADIC_NAME PAY_WAY_NAME, 
							DEBTL_ATOTAL, DEBTL_STOTAL, DEBTL_ZNJ,
							USERB_KH, USERB_HM, DEBTL_YEAR, DEBTL_MON, USERB_SQDS,
							USERB_BQDS, WATERU_QAN, WATERC_QAN, WATERS_QAN, WATERQ_QAN,
							WATERB_QAN, WATERM_STAT, 
							DEBTL_CPLUS, IS_PAY, CMETER_DATE, RECORD_DATE,
							PAY_TAG,  CONVERT(VARCHAR(100),PAY_DATE, 20) PAY_DATE, CHANGE_RATE, CHANGE_RATETAG, MONTH_TSPAY,
							RECORD_USER, LAST_TSVIOTOTAL, IS_EXCPAY, USERB_YHDM, BANK_NUMBER, 
							BANK_TABNO, BANK_PAYDATE, BANK_PAYQAN, BANK_DEALTAG, BANK_REMARK,
							WATER_PRICE, WATER_EXCPRICE, METER_CHTAG, MIXED_USEDTAG,
							EST_WATER, ROLLBACK_TAG, FREEPULL_TAG, A.CREATE_PERSON, A.CREATE_DATE,
							A.UPDATE_PERSON, A.UPDATE_DATE, VOLUME_NO, BANK_FLOWNO
			FROM 		FH_DEBTLIST A
			LEFT JOIN 
							FH_DATADIC B
				ON
							A.PAY_WAY = B.DATADIC_VALUE AND B.DATADIC_TYPE = @DATADIC_TYPE
			WHERE 	DEBTL_YEAR = @DEBTL_YEAR AND DEBTL_MON = @DEBTL_MON AND USERB_KH = @USERB_KH
		END
  ELSE
		BEGIN
			SET @TABLE_NAME = 'FH_DEBTHIS' + CAST(@DEBTL_YEAR AS VARCHAR(4));
			--判断表名是否存在
			IF OBJECT_ID(@TABLE_NAME, N'U') IS NOT NULL
				BEGIN
						SET @STATEMENT = 
						'
							SELECT  DEBTLIST_ID, WATERT_NO, WATERP_QAN, PAY_WAY, PAY_WAY_NAME,
											CASE 
														WHEN PAY_WAY IS NULL OR PAY_WAY = ''0''
															THEN DEBTL_ATOTAL + YSWYJ 
													  ELSE DEBTL_ATOTAL
											END DEBTL_ATOTAL,
											DEBTL_STOTAL,
											CASE 
														WHEN PAY_WAY IS NULL OR PAY_WAY = ''0''
															THEN DEBTL_ZNJ + YSWYJ 
													  ELSE DEBTL_ZNJ
											END DEBTL_ZNJ,
											USERB_KH, USERB_HM, DEBTL_YEAR, DEBTL_MON, USERB_SQDS,
											USERB_BQDS, WATERU_QAN, WATERC_QAN, WATERS_QAN, WATERQ_QAN,
											WATERB_QAN, WATERM_STAT, 
											DEBTL_CPLUS, IS_PAY, CMETER_DATE, RECORD_DATE,
											PAY_TAG,  CONVERT(VARCHAR(100),PAY_DATE, 20) PAY_DATE, CHANGE_RATE, CHANGE_RATETAG, MONTH_TSPAY,
											RECORD_USER, LAST_TSVIOTOTAL, IS_EXCPAY, USERB_YHDM, BANK_NUMBER, 
											BANK_TABNO, BANK_PAYDATE, BANK_PAYQAN, BANK_DEALTAG, BANK_REMARK,
											WATER_PRICE, WATER_EXCPRICE, METER_CHTAG, MIXED_USEDTAG,
											EST_WATER, ROLLBACK_TAG, FREEPULL_TAG, CREATE_PERSON, CREATE_DATE,
											UPDATE_PERSON, UPDATE_DATE, VOLUME_NO, BANK_FLOWNO
							FROM 		(
								SELECT	DEBTLIST_ID, WATERT_NO, WATERP_QAN, PAY_WAY, B.DATADIC_NAME PAY_WAY_NAME,
												DEBTL_ATOTAL, DEBTL_STOTAL, ISNULL(DEBTL_ZNJ, 0) DEBTL_ZNJ, 
												DBO.FUNC_CALC_ZNJ(DEBTL_YEAR, DEBTL_MON, DEBTL_ATOTAL, NULL) YSWYJ,
												USERB_KH, USERB_HM, DEBTL_YEAR, DEBTL_MON, USERB_SQDS,
												USERB_BQDS, WATERU_QAN, WATERC_QAN, WATERS_QAN, WATERQ_QAN,
												WATERB_QAN, WATERM_STAT, 
												DEBTL_CPLUS, IS_PAY, CMETER_DATE, RECORD_DATE,
												PAY_TAG,  CONVERT(VARCHAR(100),PAY_DATE, 20) PAY_DATE, CHANGE_RATE, CHANGE_RATETAG, MONTH_TSPAY,
												RECORD_USER, LAST_TSVIOTOTAL, IS_EXCPAY, USERB_YHDM, BANK_NUMBER, 
												BANK_TABNO, BANK_PAYDATE, BANK_PAYQAN, BANK_DEALTAG, BANK_REMARK,
												WATER_PRICE, WATER_EXCPRICE, METER_CHTAG, MIXED_USEDTAG,
												EST_WATER, ROLLBACK_TAG, FREEPULL_TAG, A.CREATE_PERSON, A.CREATE_DATE,
												A.UPDATE_PERSON, A.UPDATE_DATE, VOLUME_NO, BANK_FLOWNO
								FROM		FH_DEBTOWNHIS A
								LEFT JOIN  
												FH_DATADIC B
									ON
												A.PAY_WAY = B.DATADIC_VALUE AND B.DATADIC_TYPE =  ''' + @DATADIC_TYPE + '''
								WHERE 	DEBTL_YEAR = ' + CAST(@DEBTL_YEAR AS VARCHAR(4)) + 
												' AND DEBTL_MON = ' + CAST(@DEBTL_MON AS VARCHAR(4)) +  
												' AND USERB_KH = ''' + @USERB_KH + '''
								UNION   ALL
								SELECT	DEBTLIST_ID, WATERT_NO, WATERP_QAN, PAY_WAY, B.DATADIC_NAME PAY_WAY_NAME,
												DEBTL_ATOTAL, DEBTL_STOTAL, ISNULL(DEBTL_ZNJ, 0) DEBTL_ZNJ, 
												DBO.FUNC_CALC_ZNJ(DEBTL_YEAR, DEBTL_MON, DEBTL_ATOTAL, NULL) YSWYJ,
												USERB_KH, USERB_HM, DEBTL_YEAR, DEBTL_MON, USERB_SQDS,
												USERB_BQDS, WATERU_QAN, WATERC_QAN, WATERS_QAN, WATERQ_QAN,
												WATERB_QAN, WATERM_STAT, 
												DEBTL_CPLUS, IS_PAY, CMETER_DATE, RECORD_DATE,
												PAY_TAG,  CONVERT(VARCHAR(100),PAY_DATE, 20) PAY_DATE, CHANGE_RATE, CHANGE_RATETAG, MONTH_TSPAY,
												RECORD_USER, LAST_TSVIOTOTAL, IS_EXCPAY, USERB_YHDM, BANK_NUMBER, 
												BANK_TABNO, BANK_PAYDATE, BANK_PAYQAN, BANK_DEALTAG, BANK_REMARK,
												WATER_PRICE, WATER_EXCPRICE, METER_CHTAG, MIXED_USEDTAG,
												EST_WATER, ROLLBACK_TAG, FREEPULL_TAG, A.CREATE_PERSON, A.CREATE_DATE,
												A.UPDATE_PERSON, A.UPDATE_DATE, VOLUME_NO, BANK_FLOWNO
								FROM		' + @TABLE_NAME + ' A
								LEFT JOIN  
												FH_DATADIC B
									ON
												A.PAY_WAY = B.DATADIC_VALUE AND B.DATADIC_TYPE = ''' + @DATADIC_TYPE + '''
								WHERE 	DEBTL_YEAR = ' + CAST(@DEBTL_YEAR AS VARCHAR(4)) + 
												' AND DEBTL_MON = ' + CAST(@DEBTL_MON AS VARCHAR(4)) +  
												' AND USERB_KH = ''' + @USERB_KH + '''
								
							) T
							ORDER BY DEBTLIST_ID DESC, WATERT_NO DESC
						';
						/*SET @STATEMENT = 'SELECT	WATERT_NO, WATERP_QAN, PAY_WAY, DEBTL_ATOTAL, DEBTL_STOTAL, 
												ISNULL(DEBTL_ZNJ, 0) DEBTL_ZNJ, 
												DBO.FUNC_CALC_ZNJ(DEBTL_YEAR, DEBTL_MON, DEBTL_ATOTAL, NULL) YSWYJ
								FROM		FH_DEBTOWNHIS
								WHERE 	DEBTL_YEAR = ' + CAST(@DEBTL_YEAR AS VARCHAR(4)) + 
												' AND DEBTL_MON = ' + CAST(@DEBTL_MON AS VARCHAR(4)) +  
												' AND USERB_KH = ' + @USERB_KH ;
					EXEC SP_EXECUTESQL @STATEMENT, 
						N'@USERB_KH VARCHAR(36), @DEBTL_YEAR INT, @DEBTL_MON INT, @TABLE_NAME VARCHAR(100)', 
						@USERB_KH, @DEBTL_YEAR, @DEBTL_MON, @TABLE_NAME */
						--PRINT @STATEMENT;
						EXEC  (@STATEMENT);
				END
			ELSE
				BEGIN
						SELECT	DEBTLIST_ID, WATERT_NO, WATERP_QAN, PAY_WAY, PAY_WAY_NAME,
											CASE 
														WHEN PAY_WAY IS NULL OR PAY_WAY = '0'
															THEN DEBTL_ATOTAL + YSWYJ 
													  ELSE DEBTL_ATOTAL
											END DEBTL_ATOTAL,
											DEBTL_STOTAL,
											CASE 
														WHEN PAY_WAY IS NULL OR PAY_WAY = '0'
															THEN DEBTL_ZNJ + YSWYJ 
													  ELSE DEBTL_ZNJ
											END DEBTL_ZNJ,
											USERB_KH, USERB_HM, DEBTL_YEAR, DEBTL_MON, USERB_SQDS,
											USERB_BQDS, WATERU_QAN, WATERC_QAN, WATERS_QAN, WATERQ_QAN,
											WATERB_QAN, WATERM_STAT, 
											DEBTL_CPLUS, IS_PAY, CMETER_DATE, RECORD_DATE,
											PAY_TAG,  CONVERT(VARCHAR(100),PAY_DATE, 20) PAY_DATE, CHANGE_RATE, CHANGE_RATETAG, MONTH_TSPAY,
											RECORD_USER, LAST_TSVIOTOTAL, IS_EXCPAY, USERB_YHDM, BANK_NUMBER, 
											BANK_TABNO, BANK_PAYDATE, BANK_PAYQAN, BANK_DEALTAG, BANK_REMARK,
											WATER_PRICE, WATER_EXCPRICE, METER_CHTAG, MIXED_USEDTAG,
											EST_WATER, ROLLBACK_TAG, FREEPULL_TAG, CREATE_PERSON, CREATE_DATE,
											UPDATE_PERSON, UPDATE_DATE, VOLUME_NO, BANK_FLOWNO
							FROM 		(
								SELECT	DEBTLIST_ID, WATERT_NO, WATERP_QAN, PAY_WAY, B.DATADIC_NAME PAY_WAY_NAME,
												DEBTL_ATOTAL, DEBTL_STOTAL, ISNULL(DEBTL_ZNJ, 0) DEBTL_ZNJ, 
												DBO.FUNC_CALC_ZNJ(DEBTL_YEAR, DEBTL_MON, DEBTL_ATOTAL, NULL) YSWYJ,
												USERB_KH, USERB_HM, DEBTL_YEAR, DEBTL_MON, USERB_SQDS,
												USERB_BQDS, WATERU_QAN, WATERC_QAN, WATERS_QAN, WATERQ_QAN,
												WATERB_QAN, WATERM_STAT, 
												DEBTL_CPLUS, IS_PAY, CMETER_DATE, RECORD_DATE,
												PAY_TAG,  CONVERT(VARCHAR(100),PAY_DATE, 20) PAY_DATE, CHANGE_RATE, CHANGE_RATETAG, MONTH_TSPAY,
												RECORD_USER, LAST_TSVIOTOTAL, IS_EXCPAY, USERB_YHDM, BANK_NUMBER, 
												BANK_TABNO, BANK_PAYDATE, BANK_PAYQAN, BANK_DEALTAG, BANK_REMARK,
												WATER_PRICE, WATER_EXCPRICE, METER_CHTAG, MIXED_USEDTAG,
												EST_WATER, ROLLBACK_TAG, FREEPULL_TAG, A.CREATE_PERSON, A.CREATE_DATE,
												A.UPDATE_PERSON, A.UPDATE_DATE, VOLUME_NO, BANK_FLOWNO
								FROM		FH_DEBTOWNHIS A
								LEFT JOIN  
												FH_DATADIC B
									ON
												A.PAY_WAY = B.DATADIC_VALUE AND B.DATADIC_TYPE = @DATADIC_TYPE
								WHERE 	DEBTL_YEAR = @DEBTL_YEAR AND DEBTL_MON = @DEBTL_MON AND USERB_KH = @USERB_KH
							) T
				END
		END

  -- routine body goes here, e.g.
  -- SELECT 'Navicat for SQL Server'
END
GO
